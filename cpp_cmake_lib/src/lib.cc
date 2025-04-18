#include <fmt/core.h>

#include "foo/lib.h"

void foo() {
  int i = 42;
  fmt::println("hello {}", i);
}
