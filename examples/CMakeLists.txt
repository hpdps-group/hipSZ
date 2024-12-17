# Find HIP package
find_package(hip REQUIRED)

# Define the install directory for binaries
set(install_dir ${PROJECT_BINARY_DIR}/examples/bin)
set(hipSZ "hipSZ")
set(hipSZ_test_f32 "hipSZ_test_f32")
set(hipSZ_test_f64 "hipSZ_test_f64")

# Include the main include directory
include_directories(${PROJECT_SOURCE_DIR}/include)

# Compile executable binaries
add_executable(${hipSZ} hipSZ.cpp)
add_executable(${hipSZ_test_f32} hipSZ_test_f32.cpp)
add_executable(${hipSZ_test_f64} hipSZ_test_f64.cpp)

# Link the existing hipSZ_static library
target_link_libraries(${hipSZ} PRIVATE hipSZ_static)
target_link_libraries(${hipSZ_test_f32} PRIVATE hipSZ_static)
target_link_libraries(${hipSZ_test_f64} PRIVATE hipSZ_static)

# Set output paths for the compiled binary
set_target_properties(${hipSZ} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${install_dir})
set_target_properties(${hipSZ_test_f32} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${install_dir})
set_target_properties(${hipSZ_test_f64} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${install_dir})

# Set installation paths for the compiled binary
install(TARGETS ${hipSZ} DESTINATION bin)
install(TARGETS ${hipSZ_test_f32} DESTINATION bin)
install(TARGETS ${hipSZ_test_f64} DESTINATION bin)
