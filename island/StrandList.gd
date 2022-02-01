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
		if not strands_data.has(str(id)):
			strands_data[str(id)] = { name = "Strand " + str(id) }
		child.set_name(strands_data[str(id)].name)
		child.connect("rename_strand", self, "open_rename_strand")
		id += 1

func open_rename_strand(id):
	get_parent().get_node("RenameLinkPanel").visible = true
	current_rename_id = id

func save_strands():
	var save_game = File.new()
	save_game.open(Global.ISLAND_SAVE, File.WRITE)
	save_game.store_line(to_json(strands_data))
	save_game.close()

func load_strands():
	var save_strands = File.new()
	if not save_strands.file_exists(Global.ISLAND_SAVE):
		return
	save_strands.open(Global.ISLAND_SAVE, File.READ)
	strands_data = parse_json(save_strands.get_line())
	save_strands.close()

func _on_RenameBtn_pressed():
	var name = get_parent().get_node("RenameLinkPanel/VBoxContainer/HBoxContainer/NewNameInput").text
	if !name or name.length() == 0:
		return
	strands_data[str(current_rename_id)].name = name
	save_strands()
	get_child(current_rename_id - 1).set_name(name)
	get_parent().get_node("RenameLinkPanel").visible = false

