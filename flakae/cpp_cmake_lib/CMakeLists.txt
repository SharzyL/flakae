cmake_minimum_required(VERSION 3.24)

project(foo VERSION 0.1.0 LANGUAGES CXX)

find_package(spdlog 1.15.1 REQUIRED)
find_package(fmt 10.2.1 REQUIRED)

message(STATUS "Init ${PROJECT_NAME} v${PROJECT_VERSION}. Build Type: ${CMAKE_BUILD_TYPE}")

set(LIB_NAME foo)

add_library(${LIB_NAME} SHARED src/lib.cc)
target_compile_features(${LIB_NAME} PRIVATE cxx_std_23)

target_link_libraries(${LIB_NAME} PUBLIC fmt::fmt)

target_include_directories(${LIB_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# install headers
install(DIRECTORY include/foo DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

include(CMakePackageConfigHelpers)

# generate foo-config.cmake
configure_package_config_file(
    cmake/foo-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/foo-config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_NAME}
    PATH_VARS CMAKE_INSTALL_INCLUDEDIR
)

# generate foo-config-version.cmake
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/foo-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

# declare foo-targets target
install(TARGETS ${LIB_NAME}
    EXPORT ${LIB_NAME}-targets
    PUBLIC_HEADER
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${LIB_NAME}
)

# install foo-config.cmake and foo-config-version.cmake
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/foo-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/foo-config-version.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_NAME}
)

# generate foo-targets.cmake and install
install(EXPORT ${LIB_NAME}-targets
    NAMESPACE ${LIB_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${LIB_NAME}
)

