cmake_minimum_required(VERSION 3.24)

project(cppground)

set(CMAKE_CXX_STANDARD 20)

find_package(spdlog 1.15.1 REQUIRED)
find_package(fmt    10.2.1 REQUIRED)

message(STATUS "Init ${PROJECT_NAME}. Build Type: ${CMAKE_BUILD_TYPE}")

add_executable(main src/main.cc)
target_link_libraries(main spdlog::spdlog fmt::fmt)

install(TARGETS main)

