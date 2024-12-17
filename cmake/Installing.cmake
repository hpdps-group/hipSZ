include(GNUInstallDirs)

# Set default install prefix
if(DEFINED CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    message(STATUS "CMAKE_INSTALL_PREFIX is not set, defaulting to ${CMAKE_SOURCE_DIR}/install")
    set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}/install" CACHE PATH "Install path" FORCE)
else()
    message(STATUS "CMAKE_INSTALL_PREFIX set to ${CMAKE_INSTALL_PREFIX}")
endif()

# Install hipSZ.h in the include directory
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/include/hipSZ.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# **Gather all .h files from include/hipSZ/** and install them
file(GLOB hipSZ_headers ${CMAKE_CURRENT_SOURCE_DIR}/include/hipSZ/*.h)

# Install the hipSZ headers into include/hipSZ directory
install(FILES ${hipSZ_headers}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/hipSZ
)

# Install shared library and headers
install(TARGETS hipSZ_shared
        EXPORT hipSZTargets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}    # for executables
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}    # for shared libraries
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}  # for public headers (hipSZ.h)
)

# Install static library without headers to avoid duplication
install(TARGETS hipSZ_static
        EXPORT hipSZTargets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}    # for static libraries
)

# Generate and install export file only once
install(EXPORT hipSZTargets
        FILE hipSZTargets.cmake
        NAMESPACE hipSZ::
        DESTINATION cmake
)

include(CMakePackageConfigHelpers)

# Generate and install version and config files
write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/hipSZConfigVersion.cmake"
        VERSION "${PROJECT_VERSION}"
        COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(${CMAKE_CURRENT_SOURCE_DIR}/Config.cmake.in
        "${CMAKE_CURRENT_BINARY_DIR}/hipSZConfig.cmake"
        INSTALL_DESTINATION cmake
)

install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/hipSZConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/hipSZConfigVersion.cmake"
        DESTINATION cmake
)

# Export the build tree
export(EXPORT hipSZTargets
        FILE "${CMAKE_CURRENT_BINARY_DIR}/cmake/hipSZTargets.cmake"
        NAMESPACE hipSZ::
)
