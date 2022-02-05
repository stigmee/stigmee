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

extends HBoxContainer

var id = -1
var strand_resource

signal rename_strand
signal clear_strand

func _ready():
	strand_resource = load("res://strand/Strand.tscn")

func set_id(new_id):
	id = new_id

func set_name(name):
	$Open.text = name

func _on_Open_pressed():
	var strand = strand_resource.instance()
	find_parent("Spatial").find_node("Strand").init(id)
	find_parent("Spatial").get_node("OrbitCamera").set_zoom(3)
	find_parent("Spatial").find_node("Strand").visible = true
	find_parent("Island").visible = false
	for child in find_parent("Island").get_children():
		child.visible = false
	for child in find_parent("Spatial").find_node("Strand").get_children():
		if child.name != "Interface":
			child.visible = true

func _on_Rename_pressed():
	emit_signal('rename_strand', id)

func _on_Clear_pressed():
	emit_signal('clear_strand', id)

