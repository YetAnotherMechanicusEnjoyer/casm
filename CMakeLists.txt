cmake_minimum_required(VERSION 3.20)
set(TARGET casm)
project(${TARGET} LANGUAGES NONE) # Bash script: nothing to compile, only installed and packaged

# =========================
# Options
# =========================
set(CASM_VERSION "" CACHE STRING "Package version (default: computed from git, like the AUR / Nix publishers)")
set(CASM_PACKAGE_RELEASE "1" CACHE STRING "Package release (pkgrel of the AUR package)")
set(CASM_PACKAGE_MAINTAINER "Frezzydy <frezzydygaming@gmail.com>" CACHE STRING "Packager of the DEB / RPM (maintainer of the AUR package)")

# =========================
# Version
# =========================
# Same rules as the 'Extract Git Tag version' step of .github/workflows/aur.yml:
# v1.2.0-3-gabc1234 -> 1.2.0.r3.gabc1234, no tag -> 0.0.0r<commit count>.g<hash>
if(CASM_VERSION STREQUAL "")
    find_package(Git QUIET) # Version from the history
    if(GIT_FOUND)
        execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --long --tags --abbrev=7
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            OUTPUT_VARIABLE GIT_DESCRIBE
            RESULT_VARIABLE GIT_DESCRIBE_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        if(GIT_DESCRIBE_RESULT EQUAL 0)
            string(REGEX REPLACE "^v" "" CASM_VERSION "${GIT_DESCRIBE}")
            string(REGEX REPLACE "([^-]*-g)" "r\\1" CASM_VERSION "${CASM_VERSION}")
            string(REPLACE "-" "." CASM_VERSION "${CASM_VERSION}")
        else()
            execute_process(
                COMMAND ${GIT_EXECUTABLE} rev-list --count HEAD
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE GIT_COUNT
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            execute_process(
                COMMAND ${GIT_EXECUTABLE} rev-parse --short=7 HEAD
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE GIT_HASH
                OUTPUT_STRIP_TRAILING_WHITESPACE
                ERROR_QUIET
            )
            if(GIT_COUNT AND GIT_HASH)
                set(CASM_VERSION "0.0.0r${GIT_COUNT}.g${GIT_HASH}")
            endif()
        endif()
    endif()
endif()
if(CASM_VERSION STREQUAL "")
    set(CASM_VERSION "0.0.0") # Sources without git history (archive)
    message(WARNING "No git history: packages built as version ${CASM_VERSION}")
endif()
if(NOT CASM_VERSION MATCHES "^[0-9][A-Za-z0-9.+~]*$")
    message(FATAL_ERROR "Invalid package version '${CASM_VERSION}': digits first, then letters, digits, '.', '+' or '~' (no '-')")
endif()
message(STATUS "casm package version: ${CASM_VERSION}-${CASM_PACKAGE_RELEASE}")

# =========================
# Installation
# =========================
# Same files as the PKGBUILD: /usr/bin/casm and /usr/share/licenses/casm/LICENSE
install(
    PROGRAMS ${CMAKE_SOURCE_DIR}/casm
    DESTINATION bin
)
install(
    FILES ${CMAKE_SOURCE_DIR}/LICENSE
    DESTINATION share/licenses/${TARGET}
)

# =========================
# Package Building
# =========================
# Same metadata as the AUR (PKGBUILD of casm-cli) and Nix (flake.nix) packages
set(CPACK_PACKAGE_NAME ${TARGET})
set(CPACK_PACKAGE_VENDOR "YetAnotherMechanicusEnjoyer")
set(CPACK_PACKAGE_CONTACT "${CASM_PACKAGE_MAINTAINER}")
set(CPACK_PACKAGE_VERSION ${CASM_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "A small build system for NASM projects")
set(CPACK_PACKAGE_DESCRIPTION "casm assembles and links NASM projects from a build.casm file: init, build, run (under valgrind or strace) and clean.")
set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/YetAnotherMechanicusEnjoyer/casm")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")

set(CPACK_GENERATOR "RPM;DEB")

# Runtime dependencies (runtimeInputs of flake.nix, depends of the PKGBUILD): bash >= 4.4 checked by the script,
# gcc only for 'linker = cc', valgrind / strace only for 'casm run --valgrind / --strace'

# RPM (noarch: casm-<version>-<release>.noarch.rpm)
set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
set(CPACK_RPM_PACKAGE_RELEASE "${CASM_PACKAGE_RELEASE}")
set(CPACK_RPM_PACKAGE_ARCHITECTURE "noarch")
set(CPACK_RPM_PACKAGE_RELOCATABLE OFF)
set(CPACK_RPM_PACKAGE_LICENSE "GPL-3.0-only")
set(CPACK_RPM_PACKAGE_GROUP "Development/Tools")
set(CPACK_RPM_PACKAGE_URL "${CPACK_PACKAGE_HOMEPAGE_URL}")
set(CPACK_RPM_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}")
set(CPACK_RPM_PACKAGE_REQUIRES "bash >= 4.4, nasm, binutils, coreutils")
set(CPACK_RPM_PACKAGE_RECOMMENDS "gcc")
set(CPACK_RPM_PACKAGE_SUGGESTS "valgrind, strace")
set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION /usr/share/licenses) # Owned by the filesystem package

# Debian (all: casm_<version>-<release>_all.deb)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_RELEASE "${CASM_PACKAGE_RELEASE}")
set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "all")
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CASM_PACKAGE_MAINTAINER}")
set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${CPACK_PACKAGE_HOMEPAGE_URL}")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "bash (>= 4.4), nasm, binutils, coreutils")
set(CPACK_DEBIAN_PACKAGE_RECOMMENDS "gcc")
set(CPACK_DEBIAN_PACKAGE_SUGGESTS "valgrind, strace")

include(CPack)
