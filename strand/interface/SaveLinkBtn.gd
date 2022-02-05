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

extends Button

signal save_link

var rename_link_panel
var new_name_input

func _ready():
	var interface = find_parent("Interface")
	rename_link_panel = interface.get_node("RenameLinkPanel")
	new_name_input = interface.get_node("RenameLinkPanel/VBoxContainer/HBoxContainer/NewNameInput")
	rename_link_panel.visible = false

func _on_Button_pressed():
	var name = new_name_input.text
	if name.length() == 0:
		return
	emit_signal("save_link", name)
	rename_link_panel.visible = false

func _on_SaveLinkBtn_pressed():
	new_name_input.text = ""
	new_name_input.grab_focus()
	rename_link_panel.visible = true
