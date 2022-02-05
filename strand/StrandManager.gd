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

const NODE = preload("res://strand/Node/Node.tscn")
export var links = []
var nodes = []

var SAVE_PATH

var physicalNodes = []
var nodes_data = {}

var cef = null
var mouse_pressed = false
var placing_node = false

var current_node_id = 0
var current_url
var current_name

func init_events():
	var browser_controller = $Interface/Browser
	browser_controller.connect("prev_node", self, "prev_node")
	browser_controller.connect("next_node", self, "next_node")
	browser_controller.connect("home", self, "home")
	browser_controller.connect("browser_close", self, "browser_close")
	browser_controller.connect("browser_event", self, "browser_event")
	var save_link_btn = find_node("SaveLinkBtn")
	save_link_btn.connect("save_link", self, "save_link")

func home():
	load_link(Global.DEFAULT_SEARCH_ENGINE_URL)

func save_link(name):
	current_url = cef.get_url()
	browser_close()
	placing_node = true
	current_name = name
	Global.edit_mode = true
	$Hint/HintAddResource.visible = true

func browser_event(event):
	if not cef:
		return

	if event is InputEventMouseButton:

		if event.button_index == BUTTON_WHEEL_UP:
			cef.on_mouse_wheel(5)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			cef.on_mouse_wheel(-5)
		elif event.button_index == BUTTON_LEFT:
			mouse_pressed = event.pressed
			if event.pressed == true:
				cef.on_mouse_left_down()
			else:
				cef.on_mouse_left_up()
		elif event.button_index == BUTTON_RIGHT:
			mouse_pressed = event.pressed
			if event.pressed == true:
				cef.on_mouse_right_down()
			else:
				cef.on_mouse_right_up()
		else:
			mouse_pressed = event.pressed
			if event.pressed == true:
				cef.on_mouse_middle_down()
			else:
				cef.on_mouse_middle_up()

	elif event is InputEventMouseMotion:
		if mouse_pressed == true :
			cef.on_mouse_left_down()
		cef.on_mouse_moved(event.position.x, event.position.y)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.unicode != 0:
			cef.on_key_pressed(event.unicode, event.pressed, event.shift, event.alt, event.control)
		else:
			cef.on_key_pressed(event.scancode, event.pressed, event.shift, event.alt, event.control)
	if event.is_action_pressed("ui_cancel"):
		if $Interface.visible:
			browser_close()
		else:
			find_parent("Spatial").find_node("Island").visible = true
			find_parent("Spatial").find_node("Strand").visible = false
			for child in find_parent("Spatial").find_node("Strand").get_children():
				child.visible = false
			find_parent("Spatial").get_node("OrbitCamera").set_zoom(2)
			for child in find_parent("Spatial").find_node("Island").get_children():
				child.visible = true

func init_browser():
	if not cef:
		cef = GDCef.new()
	var browser = get_node("Interface")
	browser.visible = false
	Global.enable_orbit_camera = true

func _on_Spatial_tree_exiting():
	cef.cef_stop()
	print("CEF stopped")

func init(strand_id):
	for elem in physicalNodes:
		self.remove_child(elem)
	physicalNodes.clear()
	Global.edit_mode = false
	$Hint/HintAddResource.visible = false
	SAVE_PATH = Global.STRAND_SAVE % strand_id
	place_nodes($IslandGeneration.get_river())
	load_links()

func _ready():
	init_browser()
	init_events()

func instanciate_node(x, y, z):
	var node = NODE.instance()
	add_child(node)
	node.translate(Vector3(x,y,z))
	node.scale_object_local(Vector3(4,4,4))
	return node

func place_node(node, link, side):
	var x = node.pos.x + 3
	var y = rand_range(2,4)
	var z = node.pos.y + side * node.radius * 3
	var n = instanciate_node(x, y, z)
	physicalNodes.append(n)
	n.set_data(physicalNodes.size() - 1, null)

func place_nodes(river_nodes):
	var ratio = round(river_nodes.size() / links.size())
	var current_node = 2
	var nodes = []
	while nodes.size() <= links.size():
		nodes.append(river_nodes[current_node])
		current_node += ratio

	var side = 1
	for id in range(0, links.size()):
		place_node(nodes[id], links[id], side)
		side = -1 if side == 1 else 1

func assign_link_to_node(url, id, name):
	var data = {}
	data.url = url
	data.custom_name = name
	if !data.has("custom_name"):
		data.custom_name = url
	physicalNodes[id].set_data(id, data.custom_name)
	nodes_data[str(id)] = data
	save_links()

func save_links():
	var save_game = File.new()
	save_game.open(SAVE_PATH, File.WRITE)
	save_game.store_line(to_json(nodes_data))
	save_game.close()

func load_links():
	var save_game = File.new()
	if not save_game.file_exists(SAVE_PATH):
		return
	save_game.open(SAVE_PATH, File.READ)
	nodes_data = parse_json(save_game.get_line())
	for key in nodes_data:
		var data = nodes_data[key]
		physicalNodes[int(key)].set_data(int(key), data.custom_name)
	save_game.close()

func load_node(node_id):
	current_node_id = node_id
	if placing_node:
		assign_link_to_node(current_url, current_node_id, current_name)
		placing_node = false
		current_name = ""
		$Hint/HintAddResource.visible = false
		current_url = null
		Global.edit_mode = false
		return
	var url = Global.DEFAULT_SEARCH_ENGINE_URL
	if nodes_data.has(str(node_id)):
		url = nodes_data[str(node_id)].url
	load_link(url)

func assign_link_to_empty_node(link, id):
	assign_link_to_node(current_url, id, name)

func load_link(link):
	cef.load_url(link)
	var browser_size = $Interface/Browser/Panel.get_size()
	$Interface/Browser/Panel/Texture.set_size(browser_size)
	cef.reshape(browser_size.x, browser_size.y)
	$Interface.visible = true
	Global.enable_orbit_camera = false

func browser_close():
	$Interface.visible = false
	Global.enable_orbit_camera = true

func prev_node():
	cef.navigate_back()

func next_node():
	cef.navigate_forward()

func _process(delta):
	if cef == null or not $Interface.visible:
		return
	cef.do_message_loop_work()
	$Interface/Browser/Panel/Texture.texture = cef.get_texture()

func _on_OpenBrowser_pressed():
	load_link(Global.DEFAULT_SEARCH_ENGINE_URL)
