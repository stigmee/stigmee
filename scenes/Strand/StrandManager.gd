###############################################################################
## Stigmee: The art to sanctuarize knowledge exchanges.
## Copyright 2021-2022 Corentin CAILLEAUD <corentin.cailleaud@caillef.com>
## Copyright 2021-2022 Quentin Quadrat <lecrapouille@gmail.com>
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

# ==============================================================================
#
# ==============================================================================
const NODE = preload("res://scenes/URL/URL.tscn")
const BROWSER_EVENTS = ["prev_node", "next_node", "home", "browser_close", "browser_event"]
const FETCHING_TITLE_PLACEHOLDER = "Fetching title..."

# ==============================================================================
# Clickable moving spheres holding an URL
# ==============================================================================
const NB_NODES = 21
var nodes = []
var physicalNodes = []
var nodes_data = {}
var current_node_id = 0
var current_url
var current_name
var placing_node : bool = false

# The path of the file in where to save strand information
var save_path : String
var is_open : bool = false

func _ready():
	$BrowserGUI/CEF.connect("save_link", self, "_on_CEF_save_link")
	pass

# ==============================================================================
#
# ==============================================================================
func _on_CEF_save_link():
	print("_on_CEF_save_link")
	pass

# ==============================================================================
# "on init" event called by the SceneManager state machine.
# ==============================================================================
func load_scene():
	$Generator.init()
	pass

# ==============================================================================
# Hide or make visible the node and its child nodes.
# param[in] state: true to make visible. false to make invisible.
# ==============================================================================
func set_visibility(state : bool):
	self.visible = state
	for child in get_children():
		child.visible = state

# ==============================================================================
# "on entry" event called by the SceneManager state machine.
# param[in] data the ID of the strand
# ==============================================================================
func open_scene(data):
	is_open = true
	save_path = Global.STRAND_SAVE % data.strand_id
	Global.edit_mode = false
	$AutofillLinkPanel/VBoxContainer/HBoxContainer/Keyword.text = ""
	place_nodes($Generator.get_river())
	load_nodes()
	# FIXME I dunno how visibility works
	set_visibility(true)
	$BrowserGUI.visible = false
	$Menu.visible = false
	$Hint.visible = false
	$AutofillLinkPanel.visible = false
	pass

# ==============================================================================
# "on leaving" event called by the SceneManager state machine.
# ==============================================================================
func close_scene():
	is_open = false
	clear_nodes()
	set_visibility(false)
	pass

# ==============================================================================
# Remove dynamic spheres that hold URLs.
# ==============================================================================
func clear_nodes():
	for elem in physicalNodes:
		self.remove_child(elem)
	physicalNodes.clear()
	pass

# ==============================================================================
# FIXME
#	if current_tab != null:
#		current_url = current_tab.get_url()
#	browser_close()
# ==============================================================================
func save_link(name, url):
	current_url = url
	placing_node = true
	current_name = name
	Global.edit_mode = true
	$Hint/HintAddResource.visible = true
	pass

# ==============================================================================
#
# ==============================================================================
func get_next_empty_node_id():
	for i in range(0, len(physicalNodes) - 1):
		if not str(i) in nodes_data:
			return i
	return -1

# ==============================================================================
# 
# ==============================================================================
func instanciate_node(x, y, z):
	var node = NODE.instance()
	add_child(node)
	node.translate(Vector3(x,y,z))
	node.scale_object_local(Vector3(4,4,4))
	return node

# ==============================================================================
# 
# ==============================================================================
func place_node(node, side):
	var x = node.realPos.x
	var y = node.realPos.y + 7
	var z = node.realPos.z + side * node.radius * 3 + node.radius
	var n = instanciate_node(x, y, z)
	physicalNodes.append(n)
	n.set_data(physicalNodes.size() - 1, null)
	pass

# ==============================================================================
# 
# ==============================================================================
func place_nodes(river_nodes):
	var ratio = round(river_nodes.size() / NB_NODES)
	var current_node = 2
	nodes = []
	while nodes.size() <= NB_NODES:
		nodes.append(river_nodes[current_node])
		current_node += ratio

	var side = 1
	for id in range(0, NB_NODES):
		place_node(nodes[id], side)
		side = -1 if side == 1 else 1
	pass

# ==============================================================================
# Parse the HTML document looking for the title field and display the title
# ==============================================================================
func request_html_title(id, url):
	var newHttp = HTTPRequest.new()
	add_child(newHttp)
	newHttp.request(url)
	var response = yield (newHttp, "request_completed")
	var body = response[3]
	if not body:
		assign_link_to_node(url, id, "")
		return
	var content = body.get_string_from_utf8()
	if not "<title>" in content:
		assign_link_to_node(url, id, "")
		return
	var title = content.split("<title>")[1].split("</title>")[0]
	nodes_data[str(id)].title = title
	if nodes_data[str(id)].custom_name == FETCHING_TITLE_PLACEHOLDER:
		assign_link_to_node(url, id, title.substr(0, 15))
	$BrowserGUI/Interface/VBoxContainer/TopBar/ColorRect/Title.text = title
	remove_child(newHttp)
	pass

# ==============================================================================
# Make the moving sphere holds the given URL
# ==============================================================================
func assign_link_to_node(url, id, name):
	var data = {}
	data.url = url
	if name.begins_with("https://"):
		name = FETCHING_TITLE_PLACEHOLDER
		request_html_title(id, url)
	data.custom_name = name
	if !data.has("custom_name"):
		data.custom_name = url
	physicalNodes[id].set_data(id, data.custom_name)
	nodes_data[str(id)] = data
	save_nodes()
	pass

# ==============================================================================
# Save URLs inside a json file
# ==============================================================================
func save_nodes():
	var save_game = File.new()
	save_game.open(save_path, File.WRITE)
	save_game.store_line(to_json(nodes_data))
	save_game.close()
	pass

# ==============================================================================
# Load URLs inside from a json file
# ==============================================================================
func load_nodes():
	var save_game = File.new()
	if not save_game.file_exists(save_path):
		print("Could not find file " + save_path)
		return
	save_game.open(save_path, File.READ)
	nodes_data = parse_json(save_game.get_line())
	for key in nodes_data:
		var data = nodes_data[key]
		physicalNodes[int(key)].set_data(int(key), data.custom_name)
	save_game.close()
	pass

# ==============================================================================
# Click on a moving sphere holding and URL
# ==============================================================================
func click_node(node_id):
	current_node_id = node_id
	if placing_node:
		assign_link_to_node(current_url, current_node_id, current_name)
		placing_node = false
		current_name = ""
		$Hint/HintAddResource.visible = false
		current_url = null
		Global.edit_mode = false
		request_html_title(current_node_id, current_url)
		return
	var url = Global.DEFAULT_SEARCH_ENGINE_URL
	if nodes_data.has(str(node_id)):
		url = nodes_data[str(node_id)].url
	$BrowserGUI.load_link(url, "tab1") # FIXME constant name
	var title_text = $BrowserGUI/Interface/VBoxContainer/TopBar/ColorRect/Title.text
	if not "title" in nodes_data[str(node_id)]:
		request_html_title(node_id, url)
		title_text = ""
	else:
		title_text = nodes_data[str(node_id)].title
	$BrowserGUI.visible = true
	pass

# ==============================================================================
# On $Strand/Menu GUI button pressed event
# ==============================================================================
func _on_AddUrlFromStigmarkButton_pressed():
	$AutofillLinkPanel.visible = not $AutofillLinkPanel.visible
	pass

# ==============================================================================
# On $Strand/Menu GUI button pressed event
# ==============================================================================
func _on_OpenBrowser_pressed():
	$BrowserGUI.home()
	pass

# ==============================================================================
# The user has pressed on the Stigmark search button.
# ==============================================================================
func _on_StigmarkSearch_pressed():
	var keyword = $AutofillLinkPanel/VBoxContainer/HBoxContainer/Keyword.text
	if len(keyword) == 0:
		return
	$Stigmark.search_async(keyword)
	$AutofillLinkPanel/VBoxContainer/HBoxContainer/Keyword.text = ""
	$AutofillLinkPanel.visible = false
	### FIXME
	## $Libs/CEF.
	pass

# ==============================================================================
# The user has pressed on the Stigmark search button.
# ==============================================================================
func _on_Stigmark_on_search(collections):
	for collection in collections:
		var urls = collection.urls
		for url in urls:
			var id = get_next_empty_node_id()
			if id != -1:
				assign_link_to_node(url.uri, id, url.uri)
			print(url)
	pass

# ==============================================================================
# "on update" event: allow or not the user to control the camera only when no
# browser is displayed.
# ==============================================================================
func _process(_delta):
	$Menu.visible = is_open and not $BrowserGUI.visible
	pass
