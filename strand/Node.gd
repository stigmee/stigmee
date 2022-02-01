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

func _ready():
	label = find_node("Label")
	icon = find_node("Icon")
	init_floating_sphere_movement()
	
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

func set_data(id, siteName):
	node_id = id
	$Sphere.visible = siteName != null
	icon.visible = siteName == null
	if siteName:
		siteName = siteName
		label.text = siteName
