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

signal prev_node
signal next_node
signal browser_event
signal new_search

func _on_Close_pressed():
	get_parent().get_parent().visible = false

func _on_Prev_pressed():
	emit_signal("prev_node")

func _on_Next_pressed():
	emit_signal("next_node")

func _on_Texture_gui_input(event):
	emit_signal("browser_event", event)

func _on_Search_pressed():
	emit_signal("new_search")
