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

const hover_material = preload("res://scenes/URL/node_hover_material.tres")

var node_id = null
var site_name = null
var strand_scene = null
var offset : float
const FLOATING_INVERSE_AMPLITUDE : float = 15.0 # high = low amplitude
const PLUS_HOVER_SCALING : float = 1.6

# ==============================================================================
# Init random position and rotation of the sphere.
# ==============================================================================
func _ready():
	strand_scene = find_parent("StrandScene")
	assert(strand_scene != null)
	_init_floating_sphere_movement()
	pass

# ==============================================================================
# Make the sphere floating with a wave movement. Update font size and set the
# node visible in edit mode if and only if the sit name was not previously set.
# ==============================================================================
func _process(_delta):
	_floating_sphere_movement()
	var dynamic_font_size = max(30 * (Global.zoom / 10), 15)
	$Viewport/NodeText/Label.get_font("font").set_size(dynamic_font_size)
	$Viewport/NodeText/Icon.visible = (Global.edit_mode and site_name == null)
	pass

# ==============================================================================
# Init random position and rotation of the sphere.
# ==============================================================================
func _init_floating_sphere_movement():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	offset = rng.randf_range(-10.0, 10.0)
	$Sphere.rotate_y(rng.randf_range(0, 360))
	pass

# ==============================================================================
# Make the sphere floating with a wave movement
# ==============================================================================
func _floating_sphere_movement():
	var ms = float(OS.get_ticks_msec()) / 1000
	var cosMs = cos(ms + offset) / FLOATING_INVERSE_AMPLITUDE
	var sinMs = sin(ms + offset) / FLOATING_INVERSE_AMPLITUDE
	$Sphere.translation = Vector3(cosMs, cosMs + sinMs, sinMs)
	pass

# ==============================================================================
# Set ID and site name on the current node. If set name is set as null then the
# node will be invisible.
# param[in] id unique ID
# param[in] name can be null. In this case the node will be invisble.
# ==============================================================================
func set_data(id, name):
	node_id = id
	site_name = name
	$Sphere.visible = (site_name != null)
	if site_name != null:
		$Viewport/NodeText/Label.text = site_name
	pass

# ==============================================================================
# Make the sphere reacts when the user has clicked on the sphere.
# Trigger the StrandScene::click_node() method.
# ==============================================================================
func _on_Area_input_event(_camera, event, _pos, _normale, _shapeidx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if node_id != null:
			strand_scene.click_node(node_id)
		else:
			print("Error: URL ID not set")
	pass

# ==============================================================================
# Make the sphere bigger when the user points on it.
# ==============================================================================
func _on_Area_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	$Sphere.radius = 0.35
	$Sphere.material_override = hover_material
	$Viewport/NodeText/Icon.scale *= PLUS_HOVER_SCALING
	pass

# ==============================================================================
# Resotre the sphere dimension when the user stopped pointing on it.
# ==============================================================================
func _on_Area_mouse_exited():
	Input.set_default_cursor_shape(0)
	$Sphere.radius = 0.25
	$Sphere.material_override = null
	$Viewport/NodeText/Icon.scale /= PLUS_HOVER_SCALING
	pass
