#include <atomic>
#include <chrono>
#include <cstring>
#include <emmintrin.h>
#include <print>
#include <thread>
#include <vector>

using xchglock_t = std::atomic<int>;

static inline void bad_lock(xchglock_t &x) {
  int expected = 0;
  while (!x.compare_exchange_weak(expected, 1, std::memory_order_acquire)) {
    expected = 0;
  }
}

static inline void good_lock(xchglock_t &x) {
  int expected = 0;
  while (!x.compare_exchange_weak(expected, 1, std::memory_order_acquire)) {
    while (x.load(std::memory_order_relaxed) == 1)
      _mm_pause();
    expected = 0;
  }
}

static inline void unlock(xchglock_t &x) {
  x.store(0, std::memory_order_release);
}

static xchglock_t lock_var{0};
static std::atomic<bool> stop_flag{false};
static std::vector<uint64_t> counts;

static void bad_worker(int tid) {
  uint64_t local = 0;

  while (!stop_flag.load(std::memory_order_relaxed)) {
    bad_lock(lock_var);
    local++;
    unlock(lock_var);
  }

  counts[tid] = local;
}

static void good_worker(int tid) {
  uint64_t local = 0;

  while (!stop_flag.load(std::memory_order_relaxed)) {
    good_lock(lock_var);
    local++;
    unlock(lock_var);
  }

  counts[tid] = local;
}

int main(int argc, char **argv) {
  int threads = (argc > 1) ? atoi(argv[1]) : 8;
  int seconds = (argc > 2) ? atoi(argv[2]) : 3;

  if (threads <= 0 || seconds <= 0) {
    std::println(stderr, "usage: {} [threads] [seconds]", argv[0]);
    return 2;
  }

  counts.resize(threads);

  for (auto mode : {"good", "bad"}) {
    std::vector<std::thread> ths;
    lock_var.store(0);
    stop_flag.store(false);

    auto t0 = std::chrono::steady_clock::now();

    for (int i = 0; i < threads; i++) {
      if (strcmp(mode, "good") == 0)
        ths.emplace_back(good_worker, i);
      else
        ths.emplace_back(bad_worker, i);
    }

    std::this_thread::sleep_for(std::chrono::seconds(seconds));
    stop_flag.store(true);

    uint64_t total = 0;
    for (auto &t : ths) {
      t.join();
    }

    for (auto c : counts) {
      total += c;
    }

    auto t1 = std::chrono::steady_clock::now();
    double elapsed = std::chrono::duration<double>(t1 - t0).count();
    double mops = total / elapsed / 1e6;

    std::println("mode={:>4} threads={} elapsed={:.3f} total={} ops_per_sec={:.3f} M",
                 mode, threads, elapsed, total, mops);
  }

  return 0;
}
