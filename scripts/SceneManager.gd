###############################################################################
## Stigmee: The art to sanctuarize knowledge exchanges.
## Copyright 2021-2022 Corentin CAILLEAUD <corentin.cailleaud@caillef.com>
## Copyright 2021-2022 Quentin Quadrat <lecrapouille@gmail.com>
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

# ==============================================================================
# State machine memorizing the current activated Godot scene. It calls
# load_scene() at init, calls close_scene() when the current scene is no
# longer active and calls the open_scene() when the new node is activated.
# ==============================================================================
extends Spatial

# Currently active Godot Spatial node
var current_scene = null

# ==============================================================================
# Close the current scene (state machine "on leaving" event) and load the new
# scene (state machine "on entering" event).
# param[in] new_scene: the desired Godot Spatial node to be active.
# param[in] data: extra information.
# ==============================================================================
func set_scene(new_scene, data={}):
	assert(new_scene != null)
	# The newlys scene is the one already active
	if new_scene == current_scene:
		return
	# Similar to state machine "on leaving" event.
	if current_scene != null:
		current_scene.close_scene()
		print("Scene closed: " + current_scene.name)
	# Similar to state machine "on entering" event.
	current_scene = new_scene
	current_scene.open_scene(data)
	print("Scene opened: " + current_scene.name)

# ==============================================================================
# Load all scenes (child nodes) and show the island scene.
# ==============================================================================
func _ready():
	# Load all scenes (FIXME in lazy mode)
	for scene in get_children():
		scene.set_visibility(false)
		scene.load_scene()
	# Initial scene
	switch_to_island()

# ==============================================================================
# Switch to the Scene displaying islands.
# ==============================================================================
func switch_to_island():
	set_scene($IslandScene)

# ==============================================================================
# Switch to the Scene displaying Stigmark strand.
# param[in] strand_id the strand intifier (integer).
# ==============================================================================
func switch_to_strand(strand_id):
	set_scene($StrandScene, { "strand_id": strand_id })

func quit():
	pass
