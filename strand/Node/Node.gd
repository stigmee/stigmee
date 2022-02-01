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

var node_id
var siteName
var label
var icon

var offset
var FLOATING_INVERSE_AMPLITUDE = 15 # high = low amplitude

var hover_material

var hovered = false

func _ready():
	label = find_node("Label")
	icon = find_node("Icon")
	init_floating_sphere_movement()

	hover_material = preload("res://strand/Node/node_hover_material.tres")

func init_floating_sphere_movement():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	offset = rng.randf_range(-10.0, 10.0)
	$Sphere.rotate_y(rng.randf_range(0, 360))

func on_click():
	find_parent("Root").load_node(node_id)

func _on_Area_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		on_click()

func floating_sphere_movement():
	var ms = float(OS.get_ticks_msec()) / 1000
	var cosMs = cos(ms + offset) / FLOATING_INVERSE_AMPLITUDE
	var sinMs = sin(ms + offset) / FLOATING_INVERSE_AMPLITUDE
	$Sphere.translation = Vector3(cosMs, cosMs + sinMs, sinMs)

func _process(delta):
	floating_sphere_movement()
	var dynamic_font_size = max(30 * (Global.zoom / 10), 15)
	label.get_font("font").set_size(dynamic_font_size)
	icon.visible = Global.edit_mode and siteName == null

func set_data(id, _siteName):
	node_id = id
	siteName = _siteName
	$Sphere.visible = siteName != null
	if siteName:
		label.text = siteName

func _on_Area_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	$Sphere.radius = 0.35
	$Sphere.material_override = hover_material

func _on_Area_mouse_exited():
	Input.set_default_cursor_shape(0)
	$Sphere.radius = 0.25
	$Sphere.material_override = null
