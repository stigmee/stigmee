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

extends Control

var strands_data = {}
var current_rename_id
var rename_link_panel
var rename_link_text

# ==============================================================================
#
# ==============================================================================
func init():
	rename_link_panel = $RenameLinkPanel
	rename_link_text = $RenameLinkPanel/VBoxContainer/HBoxContainer/NewNameInput
	assert(rename_link_panel != null)
	assert(rename_link_text != null)
	rename_link_panel.visible = false
	load_strands()
	var children = $StrandList.get_children()
	var id = 1
	for child in children:
		child.set_id(id)
		if not strands_data.has(str(id)):
			strands_data[str(id)] = { name = "<empty>" }
		child.set_name(strands_data[str(id)].name)
		child.connect("open_strand", self, "open_strand")
		child.connect("rename_strand", self, "open_rename_strand")
		child.connect("clear_strand", self, "clear_strand")
		id += 1
	pass

# ==============================================================================
#
# ==============================================================================
func open_strand(id):
	find_parent("SceneManager").switch_to_strand(id)
	pass

# ==============================================================================
#
# ==============================================================================
func clear_strand(id):
	var save_game = File.new()
	save_game.open(Global.STRAND_SAVE % id, File.WRITE)
	save_game.store_line("{}")
	save_game.close()
	strands_data[str(id)] = { name = "<empty>" }
	rename_strand(id, strands_data[str(id)].name)
	pass

# ==============================================================================
#
# ==============================================================================
func open_rename_strand(id):
	Global.enable_orbit_camera = false
	rename_link_text.text = ""
	rename_link_panel.visible = true
	current_rename_id = id
	pass

# ==============================================================================
#
# ==============================================================================
func save_strands():
	var save_game = File.new()
	save_game.open(Global.ISLAND_SAVE, File.WRITE)
	save_game.store_line(to_json(strands_data))
	save_game.close()
	pass

# ==============================================================================
#
# ==============================================================================
func load_strands():
	var save_strands = File.new()
	if not save_strands.file_exists(Global.ISLAND_SAVE):
		return
	save_strands.open(Global.ISLAND_SAVE, File.READ)
	strands_data = parse_json(save_strands.get_line())
	save_strands.close()
	pass

# ==============================================================================
#
# ==============================================================================
func rename_strand(id, name):
	strands_data[str(id)].name = name
	save_strands()
	get_child(id - 1).set_name(name)
	rename_link_panel.visible = false
	Global.enable_orbit_camera = true
	pass

# ==============================================================================
#
# ==============================================================================
func _on_RenameBtn_pressed():
	var name = rename_link_text.text
	if !name or name.length() == 0:
		return
	rename_strand(current_rename_id, name)
	pass
