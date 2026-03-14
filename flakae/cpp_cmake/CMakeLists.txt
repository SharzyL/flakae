cmake_minimum_required(VERSION 3.24)

project(cpp_cmake_playground)

message(STATUS "Init ${PROJECT_NAME}. Build Type: ${CMAKE_BUILD_TYPE}")

# CMake does not build tests when running tests, see https://gitlab.kitware.com/cmake/cmake/-/issues/8774
# the following flag requires CMake 3.29, which fixed the bug
set(CMAKE_SKIP_TEST_ALL_DEPENDENCY FALSE)

set(CMAKE_CXX_STANDARD 26)

add_compile_options(-Wall -Wextra)

if (CMAKE_BUILD_TYPE STREQUAL "Release")
  set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_compile_options(-fsanitize=address)
  add_link_options(-fsanitize=address)
endif()

find_package(spdlog 1.15.1 REQUIRED)
find_package(fmt    10.2.1 REQUIRED)

add_executable(${PROJECT_NAME})
target_sources(${PROJECT_NAME} PRIVATE src/main.cc)
# target_link_libraries(${PROJECT_NAME} fmt::fmt spdlog::spdlog)

install(TARGETS ${PROJECT_NAME})

