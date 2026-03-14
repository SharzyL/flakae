#include <atomic>
#include <chrono>
#include <cstring>
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
      ;
    expected = 0;
  }
}

static inline void unlock(xchglock_t &x) {
  x.store(0, std::memory_order_release);
}

struct cfg {
  int threads;
  int seconds;
  int mode;
};

static xchglock_t lock_var{0};
static std::atomic<bool> stop_flag{false};
static std::vector<uint64_t> counts;
static cfg g_cfg;

static void worker(int tid) {
  uint64_t local = 0;

  while (!stop_flag.load(std::memory_order_relaxed)) {
    if (g_cfg.mode == 0)
      bad_lock(lock_var);
    else
      good_lock(lock_var);

    local++;
    unlock(lock_var);
  }

  counts[tid] = local;
}

int main(int argc, char **argv) {
  g_cfg.threads = (argc > 1) ? atoi(argv[1]) : 8;
  g_cfg.seconds = (argc > 2) ? atoi(argv[2]) : 3;
  g_cfg.mode = (argc > 3 && strcmp(argv[3], "good") == 0) ? 1 : 0;

  if (g_cfg.threads <= 0 || g_cfg.seconds <= 0) {
    std::println(stderr, "usage: {} [threads] [seconds] [bad|good]", argv[0]);
    return 2;
  }

  std::vector<std::thread> threads;
  counts.resize(g_cfg.threads);

  auto t0 = std::chrono::steady_clock::now();

  for (int i = 0; i < g_cfg.threads; i++) {
    threads.emplace_back(worker, i);
  }

  std::this_thread::sleep_for(std::chrono::seconds(g_cfg.seconds));
  stop_flag.store(true, std::memory_order_relaxed);

  uint64_t total = 0;
  for (auto &t : threads) {
    t.join();
  }

  for (auto c : counts) {
    total += c;
  }

  auto t1 = std::chrono::steady_clock::now();
  double elapsed = std::chrono::duration<double>(t1 - t0).count();
  double mops = total / elapsed / 1e6;

  std::println("mode={} threads={} elapsed={:.3f} total={} ops_per_sec={:.3f} M",
               g_cfg.mode ? "good" : "bad", g_cfg.threads, elapsed, total, mops);

  return 0;
}
