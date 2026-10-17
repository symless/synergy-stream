# SPDX-FileCopyrightText: (C) 2024 Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

# HACK This is set when the files is included so its the real path
# calling CMAKE_CURRENT_LIST_DIR after include would return the wrong scope var
set(MY_DIR ${CMAKE_CURRENT_LIST_DIR})

set(CMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP TRUE)
set(CMAKE_INSTALL_SYSTEM_RUNTIME_DESTINATION ${CMAKE_INSTALL_LIBDIR})
include(InstallRequiredSystemLibraries)

configure_file(${MY_DIR}/pre-cpack.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/pre-cpack.cmake @ONLY)
set(CPACK_PRE_BUILD_SCRIPTS ${CMAKE_CURRENT_BINARY_DIR}/pre-cpack.cmake)

configure_file(${MY_DIR}/cpack-options.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cpack-options.cmake @ONLY)
set(CPACK_PROJECT_CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/cpack-options.cmake)

set(OS_STRING "win-${BUILD_ARCHITECTURE}")

list(APPEND CPACK_GENERATOR "ZIP")

# If Wix4+ is installed make a package
find_program(WIX_APP wix)
if (NOT "${WIX_APP}" STREQUAL "")
  set(CPACK_WIX_VERSION 4)
  set(CPACK_WIX_ARCHITECTURE ${BUILD_ARCHITECTURE})
  list(APPEND CPACK_GENERATOR "WIX")
endif()

set(CPACK_PACKAGE_NAME "${SYNERGY_DISPLAY_NAME}")

# Menu Entry
set(CPACK_WIX_PROGRAM_MENU_FOLDER "${SYNERGY_DISPLAY_NAME}")
set(CPACK_PACKAGE_EXECUTABLES "${CMAKE_PROJECT_NAME}" "${SYNERGY_DISPLAY_NAME}")

# Default Install Path
set(CPACK_PACKAGE_INSTALL_DIRECTORY "${SYNERGY_DISPLAY_NAME}")

# Wix Specific Values
# Divergence from upstream: an upgrade code of its own, so this installer never replaces Deskflow.
set(CPACK_WIX_UPGRADE_GUID "A3C62A76-13DA-45C9-A464-12B013D9FE6F")
set(CPACK_WIX_UI_BANNER "${CMAKE_SOURCE_DIR}/extra/deploy/windows/wix-banner.png")
set(CPACK_WIX_UI_DIALOG "${CMAKE_SOURCE_DIR}/extra/deploy/windows/wix-dialog.png")
set(CPACK_WIX_PRODUCT_ICON "${CMAKE_SOURCE_DIR}/extra/src/apps/res/synergy.ico")

# Required Extra Extenstions
list(APPEND CPACK_WIX_EXTENSIONS "WixToolset.Util.wixext" "WixToolset.Firewall.wixext")

# Make sure to also put the xmlns for the ext into the wix block on generated files
list(APPEND CPACK_WIX_CUSTOM_XMLNS "util=http://wixtoolset.org/schemas/v4/wxs/util" "firewall=http://wixtoolset.org/schemas/v4/wxs/firewall")

# The patch has to know the full path of our msm file
configure_file(
  ${MY_DIR}/wix-patch.xml.in
  ${CMAKE_CURRENT_BINARY_DIR}/wix-patch.xml @ONLY
)

# This patch set ups filewall rules, the service and msm module
set(CPACK_WIX_PATCH_FILE "${CMAKE_CURRENT_BINARY_DIR}/wix-patch.xml")

# Creates a DLL that can be used by our MSI for custom actions.
configure_file(
  ${MY_DIR}/wix-custom.h.in
  ${CMAKE_CURRENT_BINARY_DIR}/wix-custom.h @ONLY
)
add_library(
  wix-custom SHARED
  ${MY_DIR}/wix-custom.cpp
)
target_include_directories(wix-custom PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(wix-custom PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
)
target_link_libraries(wix-custom PRIVATE Msi)
