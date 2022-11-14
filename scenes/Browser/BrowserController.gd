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

# Entry of the popup asking to save the current url on the strand scene
var new_name_input
# Memorize if the mouse was pressed
var mouse_pressed : bool = false
# Chromium Embedded Framework (CEF) BrowserView
var current_tab = null

# ==============================================================================
#
# ==============================================================================
func _ready():
	new_name_input = $RenameLinkPanel/VBoxContainer/HBoxContainer/NewNameInput
	$CEF.visible = true
	$RenameLinkPanel.visible = false
	$Interface.visible = false
	pass

# ==============================================================================
# When leaving Godot, release CEF which will also release its browsers.
# ==============================================================================
func _on_Spatial_tree_exiting():
	$CEF.shutdown()
	print("CEF shutdown")
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
			current_tab.on_mouse_wheel_vertical(5)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			current_tab.on_mouse_wheel_vertical(-5)
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
# Callback triggred by the texture node in which web pages are displayed on.
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
	if current_tab == null:
		print("create_browser")
		current_tab = $CEF.create_browser(link, name, size.x, size.y)
	else:
		print("load_url")
		current_tab.load_url(link)
	# Make the CEF texture displayed by the node knowing how to do it
	visible = true
	$Interface/VBoxContainer/Panel/Texture.texture = current_tab.get_texture()
	$Interface.visible = true
	$RenameLinkPanel.visible = false
	pass

# ==============================================================================
# Display the previously loaded page
# ==============================================================================
func browser_close():
	$RenameLinkPanel.visible = false
	$Interface.visible = false
	pass

# ==============================================================================
# Display the previously loaded page
# ==============================================================================
func prev_node():
	if current_tab != null:
		current_tab.previous_page()
	pass

# ==============================================================================
# Display the next loaded page
# ==============================================================================
func next_node():
	if current_tab != null:
		current_tab.next_page()
	pass

# ==============================================================================
# Load the home page URL
# ==============================================================================
func home():
	load_link(Global.DEFAULT_SEARCH_ENGINE_URL, "home")
	pass

# ==============================================================================
# GUI TopBarLetf 'previous' button event. Ask to load the previous loaded page.
# ==============================================================================
func _on_Prev_pressed():
	prev_node()
	pass

# ==============================================================================
# GUI TopBarLetf 'next' button event. Ask to load the next loaded page.
# ==============================================================================
func _on_Next_pressed():
	next_node()
	pass

# ==============================================================================
# GUI TopBarLetf 'home' button event. Ask to load the home page.
# ==============================================================================
func _on_Home_pressed():
	home()
	pass

# ==============================================================================
# GUI TopBarRight 'save link' button event. Save the current page into stigmark.
# ==============================================================================
func _on_SaveLinkBtn_pressed():
	new_name_input.text = ""
	new_name_input.grab_focus()
	$Interface.visible = false
	$RenameLinkPanel.visible = true
	pass

# ==============================================================================
# GUI TopBarRight 'close' button event. Close the CEF browser interface.
# ==============================================================================
func _on_Close_pressed():
	browser_close()
	pass

# ==============================================================================
# GUI RenameLinkPanel popup 'save the URL to a strand' button event.
# ==============================================================================
func _on_SaveResourceButton_pressed():
	var name = new_name_input.text
	if name.length() == 0:
		return
	var strand_scene = find_parent("StrandScene")
	assert(strand_scene != null)
	strand_scene.save_link(name, current_tab.get_url())
	$Interface.visible = false
	$RenameLinkPanel.visible = false
	pass
