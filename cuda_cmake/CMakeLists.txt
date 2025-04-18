cmake_minimum_required(VERSION 3.24 FATAL_ERROR)

project(cuda_cmake_ground LANGUAGES CUDA CXX)

find_package(CUDAToolkit REQUIRED)

add_executable(main src/main.cu)

install(TARGETS main)

