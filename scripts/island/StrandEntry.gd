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

signal open_strand
signal rename_strand
signal clear_strand

func set_id(new_id):
	id = new_id

func set_name(name):
	$Open.text = name

func _on_Open_pressed():
	emit_signal('open_strand', id)

func _on_Rename_pressed():
	emit_signal('rename_strand', id)

func _on_Clear_pressed():
	emit_signal('clear_strand', id)

