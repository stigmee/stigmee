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

enum STATE_SCENE {
	ISLAND = 1,
	STRAND
}

var nodes = {}
var island_node
var strand_node

var current_state

func set_state(new_state, data={}):
	if new_state == current_state:
		return
	if current_state:
		nodes[current_state].close_scene()
		print("Closed " + nodes[current_state].name)

	current_state = new_state
	nodes[current_state].open_scene(data)
	print("Opened " + nodes[current_state].name)

func init_nodes_list():
	island_node = $Island
	strand_node = $Strand
	nodes[STATE_SCENE.ISLAND] = island_node
	nodes[STATE_SCENE.STRAND] = strand_node

func init():
	init_nodes_list()
	for index in nodes:
		var node = nodes[index]
		node.load_scene()
		node.close_scene()
	switch_to_island()
#	switch_to_strand(1)

func _ready():
	init()

func switch_to_island():
	set_state(STATE_SCENE.ISLAND)

func switch_to_strand(strand_id):
	set_state(STATE_SCENE.STRAND, { "strand_id": strand_id })

func quit():
	pass
