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

var new_name_input
var mouse_pressed : bool = false
# Chromium Embedded Framework (CEF) BrowserView
var current_tab = null

# ==============================================================================
# 
# ==============================================================================
func _ready():
	new_name_input = $RenameLinkPanel/VBoxContainer/HBoxContainer/NewNameInput
	$RenameLinkPanel.visible = false
	pass

# ==============================================================================
# When leaving Godot, release CEF which will also release its browsers.
# ==============================================================================
func _on_Spatial_tree_exiting():
	$CEF.shutdown()
	print("CEF stopped")
	pass

# ==============================================================================
# Make the CEF browser reacts from mouse and keyboard events.
# ==============================================================================
func _unhandled_input(event):
	if current_tab == null:
		return
	if event is InputEventKey:
		if event.unicode != 0:
			current_tab.on_key_pressed(event.unicode, event.pressed, event.shift, event.alt, event.control)
		else:
			current_tab.on_key_pressed(event.scancode, event.pressed, event.shift, event.alt, event.control)
	if event.is_action_pressed("ui_cancel"):
		if $Interface.visible:
			browser_close()
		else:
			find_parent("SceneManager").switch_to_island()
	pass

# ==============================================================================
# Make the CEF browser reacts from mouse and keyboard events.
# ==============================================================================
func browser_event(event):
	if current_tab == null:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			current_tab.on_mouse_wheel(5)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			current_tab.on_mouse_wheel(-5)
		elif event.button_index == BUTTON_LEFT:
			mouse_pressed = event.pressed
			if event.pressed == true:
				current_tab.on_mouse_left_down()
			else:
				current_tab.on_mouse_left_up()
		elif event.button_index == BUTTON_RIGHT:
			mouse_pressed = event.pressed
			if event.pressed == true:
				current_tab.on_mouse_right_down()
			else:
				current_tab.on_mouse_right_up()
		else:
			mouse_pressed = event.pressed
			if event.pressed == true:
				current_tab.on_mouse_middle_down()
			else:
				current_tab.on_mouse_middle_up()
	elif event is InputEventMouseMotion:
		if mouse_pressed == true :
			current_tab.on_mouse_left_down()
		current_tab.on_mouse_moved(event.position.x, event.position.y)
	pass

# ==============================================================================
# Make the CEF browser reacts from mouse and keyboard events.
# ==============================================================================
func _on_Texture_gui_input(event):
	browser_event(event)
	pass

# ==============================================================================
# Callback when the URL has been loaded
# ==============================================================================
#unc _on_page_loaded(node):
#	print("The browser " + node.name + " has loaded " + node.get_url())
#	#$Interface.visible = true
#	pass

# ==============================================================================
# Create a new CEF browser and load the given URL.
# param[in] link: the desired URL
# param[in] name: the browser name
# ==============================================================================
func load_link(link : String, name : String):
	# Set the page dimension
	var size = $Interface/VBoxContainer/Panel.get_size()
	$Interface/VBoxContainer/Panel/Texture.set_size(size)
	# Create a new CEF browser as child node and load the URL
	current_tab = $CEF.create_browser(link, name, size.x, size.y)
	# Make the CEF texture displayed by the node knowing how to do it
	$Interface/VBoxContainer/Panel/Texture.texture = current_tab.get_texture()
	self.visible = true
	pass

# ==============================================================================
# Display the previously loaded page
# ==============================================================================
func browser_close():
	self.visible = false
	pass

# ==============================================================================
# GUI button event.
# ==============================================================================
func _on_Close_pressed():
	browser_close()
	pass

# ==============================================================================
# Display the previously loaded page
# ==============================================================================
func prev_node():
	if current_tab != null:
		current_tab.previous_page()
	pass

# ==============================================================================
# GUI button event.
# ==============================================================================
func _on_Prev_pressed():
	prev_node()
	pass

# ==============================================================================
# Display the next loaded page
# ==============================================================================
func next_node():
	if current_tab != null:
		current_tab.next_page()
	pass

# ==============================================================================
# GUI button event.
# ==============================================================================
func _on_Next_pressed():
	next_node()
	pass

# ==============================================================================
# Load the home page URL
# ==============================================================================
func home():
	load_link(Global.DEFAULT_SEARCH_ENGINE_URL, "home")
	visible = true
	pass

# ==============================================================================
# GUI button event.
# ==============================================================================
func _on_Home_pressed():
	home()
	pass

# ==============================================================================
# GUI button event.
# ==============================================================================
func _on_ResourceButton_pressed():
	var name = new_name_input.text
	if name.length() == 0:
		return
	emit_signal("save_link", name)
	$RenameLinkPanel.visible = false
	pass

# ==============================================================================
# GUI button event.
# ==============================================================================
func _on_SaveLinkBtn_pressed():
	new_name_input.text = ""
	new_name_input.grab_focus()
	self.visible = false
	$RenameLinkPanel.visible = true
	pass
