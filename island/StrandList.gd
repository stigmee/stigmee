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

extends VBoxContainer

var strands_data = {}
var current_rename_id

func _ready():
	get_parent().get_node("RenameLinkPanel").visible = false
	load_strands()
	var children = get_children()
	var id = 1
	for child in children:
		child.set_id(id)
		if not strands_data.has(id):
			strands_data[id] = { name = "Strand " + str(id) }
		child.set_name(strands_data[id].name)
		child.connect("rename_strand", self, "open_rename_strand")
		id += 1
	save_strands()

func open_rename_strand(id):
	get_parent().get_node("RenameLinkPanel").visible = true
	current_rename_id = id

func save_strands():
	var save_game = File.new()
	save_game.open("user://savestrands.save", File.WRITE)
	save_game.store_line(to_json(strands_data))
	save_game.close()

func load_strands():
	var save_strands = File.new()
	if not save_strands.file_exists("user://savestrands.save"):
		return {}
	save_strands.open("user://savestrands.save", File.READ)
	strands_data = parse_json(save_strands.get_line())
	for key in strands_data:
		var data = strands_data[key]
		key = int(key)
		if !data.has("name"):
			data.custom_name = "Strand " + str(key)
		get_child(key - 1).set_id(key)
		get_child(key - 1).set_name(data.name)
	save_strands.close()


func _on_RenameBtn_pressed():
	var name = get_parent().get_node("RenameLinkPanel/VBoxContainer/HBoxContainer/NewNameInput").text
	if !name or name.length() == 0:
		return
	strands_data[current_rename_id].name = name
	get_child(current_rename_id - 1).set_name(name)
	get_parent().get_node("RenameLinkPanel").visible = false
