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
# Pathes for se
# ==============================================================================
var ISLAND_SAVE = "user://saveisland.save"
var STRAND_SAVE = "user://savestrand%d.save"

# BROWSER CONFIG
var DEFAULT_SEARCH_ENGINE_URL = "https://google.com"

# GLOBALS
var strand_id
var enable_orbit_camera = true
var zoom = 1
var edit_mode = false
