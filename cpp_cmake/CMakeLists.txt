cmake_minimum_required(VERSION 3.24)

project(cpp_cmake_playground)

set(CMAKE_CXX_STANDARD 20)

find_package(spdlog 1.15.1 REQUIRED)
find_package(fmt    10.2.1 REQUIRED)

message(STATUS "Init ${PROJECT_NAME}. Build Type: ${CMAKE_BUILD_TYPE}")

add_executable(main src/main.cc)
target_link_libraries(main fmt::fmt)

install(TARGETS main)


# example of a library with headers

set(LIB_NAME foo)
add_library(${LIB_NAME} src/lib.cc)
target_link_libraries(${LIB_NAME} fmt::fmt)

# we are using target_sources, hence no need for target_include_directories
target_sources(${LIB_NAME} PUBLIC
  FILE_SET HEADERS
  BASE_DIRS include
  FILES include/lib.h)

install(
  TARGETS ${LIB_NAME}
  EXPORT ${LIB_NAME}-config
  PUBLIC_HEADER
    FILE_SET HEADERS
    DESTINATION lib/foo
)

install(
  EXPORT ${LIB_NAME}-config
  NAMESPACE ${LIB_NAME}::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_NAME}
)

