# Specify the minimum version of CMake required to build the project
cmake_minimum_required(VERSION 3.21)

# Project configuration
project(hipSZ VERSION 1.0.0 DESCRIPTION "Error-bounded GPU lossy compression library")

# Enable languages
enable_language(CXX HIP)

# Find required HIP toolkit
find_package(hip REQUIRED)

# Set C++ and HIP standards
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_HIP_STANDARD 17)
set(CMAKE_HIP_STANDARD_REQUIRED ON)

# Set HIP host compiler
# message(WARNING "--------" ${CMAKE_CXX_COMPILER})
find_program(CLANG_EXECUTABLE NAMES clang)
if(CLANG_EXECUTABLE)
    message(STATUS "Found clang: ${CLANG_EXECUTABLE}")
else()
    message(FATAL_ERROR "Could not find clang compiler")
endif()
set(CMAKE_HIP_HOST_COMPILER ${CLANG_EXECUTABLE})
# message(WARNING "--------" ${CMAKE_HIP_HOST_COMPILER})
# set(CMAKE_HIP_SEPARABLE_COMPILATION ON)
find_program(HIPCC_EXECUTABLE NAMES hipcc)
if(HIPCC_EXECUTABLE)
    message(STATUS "Found hipcc: ${HIPCC_EXECUTABLE}")
else()
    message(FATAL_ERROR "Could not find hipcc compiler")
endif()
set(CMAKE_HIP_COMPILER ${HIPCC_EXECUTABLE})
set(CMAKE_HIP_ARCHITECTURES gfx926)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set default build type to Release if not specified
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY VALUE Release)
endif()

# Disable specific warnings (adjust as needed)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-result -Wno-unsequenced -D__HIP_PLATFORM_AMD__ -DHIP_ENABLE_WARP_SYNC_BUILTINS")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-result -Wno-unsequenced -D__HIP_PLATFORM_AMD__ -DHIP_ENABLE_WARP_SYNC_BUILTINS")
set(CMAKE_HIP_FLAGS "${CMAKE_HIP_FLAGS} -Wno-unused-result -Wno-unsequenced -DHIP_ENABLE_WARP_SYNC_BUILTINS")

# List of source files
set(hipSZ_SOURCES
    src/hipSZ_kernels_f32.hip
    src/hipSZ_kernels_f64.hip
    src/hipSZ_utility.hip
    src/hipSZ_timer.hip
    src/hipSZ_entry_f32.hip
    src/hipSZ_entry_f64.hip
    src/hipSZ.hip
)

# Create static and shared libraries
add_library(hipSZ_static STATIC ${hipSZ_SOURCES})
add_library(hipSZ_shared SHARED ${hipSZ_SOURCES})

# Include directories for both libraries
target_include_directories(hipSZ_static
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/hipSZ>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_include_directories(hipSZ_shared
    PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include/hipSZ>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Link HIP runtime
target_link_libraries(hipSZ_static PRIVATE hip::host)
target_link_libraries(hipSZ_shared PRIVATE hip::host)

# Set output name for libraries
set_target_properties(hipSZ_static PROPERTIES OUTPUT_NAME hipSZ)
set_target_properties(hipSZ_shared PROPERTIES OUTPUT_NAME hipSZ)

# Headers for installation
set(public_headers
    include/hipSZ.h
)

# Optionally build examples
option(hipSZ_BUILD_EXAMPLES "Option to enable building example programs" ON)
if (hipSZ_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif ()

# Include the Installing.cmake script
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(Installing)

# Enable CTest
enable_testing()

# Add test for installed hipSZ_test binary
add_test(NAME hipSZTest_f32 COMMAND ${CMAKE_INSTALL_PREFIX}/bin/hipSZ_test_f32)
add_test(NAME hipSZTest_f64 COMMAND ${CMAKE_INSTALL_PREFIX}/bin/hipSZ_test_f64)

# Optional: Set working directory if required
set_tests_properties(hipSZTest_f32 PROPERTIES WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin)
set_tests_properties(hipSZTest_f64 PROPERTIES WORKING_DIRECTORY ${CMAKE_INSTALL_PREFIX}/bin)
