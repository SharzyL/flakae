cmake_minimum_required(VERSION 3.24)

project(cpp_cmake_test)

set(CMAKE_CXX_STANDARD 20)

find_package(foo REQUIRED)

message(STATUS "Init ${PROJECT_NAME}. Build Type: ${CMAKE_BUILD_TYPE}")

add_executable(main src/main.cc)
target_link_libraries(main foo::foo)

install(TARGETS main)

