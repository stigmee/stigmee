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

const NODE = preload("res://strand/Node.tscn")
export var links = []
var nodes = []

var physicalNodes = []
var nodes_data = {}

var cef = null

var mouse_pressed = false

var current_node_id = 0

func init_events():
	var browser_controller = get_node("Interface/Browser/BrowserController")
	browser_controller.connect("prev_node", self, "prev_node")
	browser_controller.connect("next_node", self, "next_node")
	browser_controller.connect("browser_event", self, "browser_event")

func browser_event(event):
	if not cef:
		return

	if event is InputEventMouseButton:
		
		if event.button_index == BUTTON_WHEEL_UP:
			cef.on_mouse_wheel(5)
			print("Mouse : Wheel UP")
		elif event.button_index == BUTTON_WHEEL_DOWN:
			cef.on_mouse_wheel(-5)
			print("Mouse : Wheel DOWN")
		elif event.button_index == BUTTON_LEFT:
			if event.pressed == true:
				mouse_pressed = true
				cef.on_mouse_left_down()
				print("Mouse : LEFT_DOWN")
			else:
				mouse_pressed = false
				cef.on_mouse_left_up()
				print("Mouse : LEFT_UP")
		elif event.button_index == BUTTON_RIGHT:
			if event.pressed == true:
				mouse_pressed = true
				cef.on_mouse_right_down()
				print("Mouse : RIGHT_DOWN")
			else:
				mouse_pressed = false
				cef.on_mouse_right_up()
				print("Mouse : RIGHT_UP")
		else:
			if event.pressed == true:
				mouse_pressed = true
				cef.on_mouse_middle_down()
				print("Mouse : MIDDLE_DOWN")
			else:
				mouse_pressed = false
				cef.on_mouse_middle_up()
				print("Mouse : MIDDLE_UP")
			
			#cef.on_mouse_click(event.button_index, event.pressed)
			#cef.on_mouse_click(event.button_index, event.pressed)
			#print("Mouse : Click")
		
	elif event is InputEventMouseMotion:
		
		if mouse_pressed == true :
			print ("still pressed")
			cef.on_mouse_left_down()
		#cef.on_mouse_moved(event.position.x, event.position.y)
		cef.on_mouse_moved(event.position.x, event.position.y)
		
		
	elif event is InputEventKey:
		
		print("---------------------------------------")
		print("Key Pressed :", event.scancode, " | ", event.pressed, " | ", event.unicode, " | ", event.physical_scancode)
		print("OS :", OS.get_scancode_string(event.scancode) , " | ", OS.get_scancode_string(event.unicode))
		print("---------------------------------------")
		#cef.on_key_event(0 ,event.scancode, event.scancode)
		
		
		
		cef.on_key_pressed(event.unicode, event.pressed, 
						event.shift, event.alt, event.control)
	

func init_browser():
	cef = GDCef.new()

func _ready():
	Global.strand_id = Global.strand_id || 1
	print(Global.strand_id)
	place_nodes($IslandGeneration.get_river())
	init_browser()
	init_events()

	links = [
		"https://en.wikipedia.org/wiki/Permaculture",
		"https://www.permaculturedesign.fr/comment-faire-un-jardin-en-permaculture/",
		"https://www.youtube.com/watch?v=oRbZN3YaeUI",
		"https://www.youtube.com/watch?v=tgazUCrCNU8",
		"https://www.culturesenville.fr/blog/permaculture-definition-principes/",
		"https://www.jardiner-malin.fr/fiche/permaculture-c-est-quoi.html",
		"https://www.permaculture.co.uk/what-is-permaculture",
		"https://www.gammvert.fr/conseils/conseils-de-jardinage/7-points-cles-pour-faire-un-potager-en-permaculture"
	]
	assign_links_to_nodes(links)

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

func assign_links_to_nodes(links):
	var id = 0
	for url in links:
		var data = get_data_from_url(url)
		physicalNodes[id].set_data(id, data.site_name)
		nodes_data[id] = data
		id += 1

func load_node(node_id):
	if not nodes_data.has(node_id):
		return
	var data = nodes_data[node_id]
	load_link(data.url)
	current_node_id = node_id

func get_data_from_url(url):
	var data = {}
	data.url = url
	var size = 4
	var symbolPos = url.find(".com")
	if symbolPos == -1:
		symbolPos = url.find(".org")
		if symbolPos == -1:
			symbolPos = url.find(".fr")
			if symbolPos != -1:
				size = 3
			if symbolPos == -1:
				symbolPos = url.find(".net")
				if symbolPos == -1:
					symbolPos = url.find(".ca")
					if symbolPos != -1:
						size = 3

	if symbolPos >= 0:
		var end = symbolPos
		var begin = end - 1
		while url[begin] != ".":
			begin -= 1
		begin += 1
		data.site_name = url.substr(begin, end - begin)
		data.domain_name = url.substr(begin, end - begin + size)
	else:
		data.site_name = url.to_lower()
		data.domain_name = url.to_lower()
	return data

func load_link(link):
	cef.load_url(link)
	var browser_size = $Interface/Browser/Panel.get_size()
	$Interface/Browser/Panel/Texture.set_size(browser_size)
	cef.reshape(browser_size.x, browser_size.y)
	$Interface/Browser.visible = true

func prev_node():
	cef.navigate_back()
#	load_node(current_node_id - 1)

func next_node():
	cef.navigate_forward()
#	load_node(current_node_id + 1)

func request_add_link():
	load_link("https://google.com")

func _process(delta):
	if cef == null or not $Interface/Browser.visible:
		return
	_my_work()
	$Interface/Browser/Panel/Texture.texture = cef.get_texture()

func _my_work():
	cef.do_message_loop_work()

