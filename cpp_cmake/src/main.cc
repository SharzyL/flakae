#include <numeric>
#include <spdlog/spdlog.h>

auto main() -> int {
  spdlog::info("gcd(114, 514) = {}", std::gcd(114, 514));

  return 0;
}
