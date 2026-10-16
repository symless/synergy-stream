# SPDX-FileCopyrightText: (C) 2026 Synergy App Ltd
# SPDX-License-Identifier: MIT

# Included after Deskflow sets its CMAKE_PROJECT_* defaults and before anything reads them.

# The translation files keep Deskflow's name on disk, so their lookups need it.
set(UPSTREAM_PROJECT_NAME ${CMAKE_PROJECT_NAME})

set(CMAKE_PROJECT_NAME synergy-stream)
set(CMAKE_PROJECT_PROPER_NAME "SynergyStream")
set(CMAKE_PROJECT_REV_FQDN "com.symless.synergy-stream")
set(CMAKE_PROJECT_HOMEPAGE_URL "https://github.com/symless/synergy-stream")
set(CMAKE_PROJECT_DESCRIPTION
  "Synergy Stream continuously tracks Deskflow, the upstream community project, and comes with no warranty or guarantee."
)

# The name people read. CMAKE_PROJECT_PROPER_NAME also names a CMake target, which cannot hold a space.
set(SYNERGY_DISPLAY_NAME "Synergy Stream")

# CPack writes WiX component ids with underscores, since an id cannot hold a hyphen.
string(REPLACE "-" "_" SYNERGY_WIX_ID "${CMAKE_PROJECT_NAME}")

# GNUInstallDirs derives this from PROJECT_NAME, which stays deskflow, but the help viewer looks under the app id.
set(CMAKE_INSTALL_DOCDIR "share/doc/${CMAKE_PROJECT_NAME}")
