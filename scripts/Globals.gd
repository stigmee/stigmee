###############################################################################
## Stigmee: The art to sanctuarize knowledge exchanges.
## Copyright 2021-2022 Corentin CAILLEAUD <corentin.cailleaud@caillef.com>
##
## This file is part of Stigmee.
##
## Stigmee is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see http://www.gnu.org/licenses/.
###############################################################################

extends Spatial

# ==============================================================================
# Pathes to save Stigmee files
# The"user://" prefix points to a different directory on the user's device:
#  - On mobile and consoles, this path is unique to the project.
#  - On desktop, the engine stores user files in:
#    - on Linux at ~/.local/share/godot/app_userdata/[project_name]
#    - on macOS (since Catalina) at
#      ~/Library/Application Support/Godot/app_userdata/[project_name]
#    - on Windows at %APPDATA%\Godot\app_userdata\[project_name]
# ==============================================================================
const ISLAND_SAVE = "user://saveisland.json"
const STRAND_SAVE = "user://savestrand%d.json"

# ==============================================================================
# Stigmee settings
# ==============================================================================
var DEFAULT_SEARCH_ENGINE_URL = "https://duckduckgo.com/"

# ==============================================================================
# GLOBALS FIXME to be removed
# ==============================================================================
var enable_orbit_camera = true
var zoom = 1
