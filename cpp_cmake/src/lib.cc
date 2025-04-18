#include <fmt/core.h>

#include "lib.h"

void foo() {
  int i = 42;
  fmt::println("hello {}", i);
}
