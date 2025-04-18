#include <fmt/core.h>
#include <spdlog/spdlog.h>

int main(int argc, char *argv[]) {
  spdlog::info("welcome: {}", 4);
  fmt::println("fmt {}", 42);

  return 0;
}
