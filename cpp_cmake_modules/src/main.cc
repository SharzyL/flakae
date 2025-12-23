#include <spdlog/spdlog.h>

import std;
import foo;

auto main() -> int {
  spdlog::info("gcd(114, 514) = {}", gcd(114, 514));
  std::println("std::gcd(114, 514) = {}", std::gcd(114, 514));

  return 0;
}
