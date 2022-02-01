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

const NB_CORNERS = 6
const START_ANGLE = PI / 2
const CORNER_RADIUS = 2 * PI / NB_CORNERS
const NB_RINGS = 20
const SCALE = 1
const POLYGON_SCALE = 0.5

const SPEED = 0

const MAP_INTENSITY = 3 # height of mountains
const MAP_PERIOD = 10 # size of mountains
const MAP_PERSISTENCE = 0.1 # 0.1 = smooth, 1 = not smooth

var noise
var BLUE_MATERIAL
var WHITE_MATERIAL

var st
var vertexes = []
var m

func get_noise(x,y):
	var pos = Vector2(x,y)
	if pos.distance_to(Vector2.ZERO) > 15:
		return -10
	if pos.distance_to(Vector2.ZERO) > 10:
		return -2
	return noise.get_noise_2d(x, y) * MAP_INTENSITY + MAP_INTENSITY / 2 - 2

func flatten_world(array):
	for i in range(1, array.size() -1):
		var curr = array[i]
		if curr.y <= -2 * MAP_INTENSITY:
			continue
		var prev = array[i - 1]
		var next = array[i + 1]
		if abs((curr.y + prev.y + next.y) / 3 - curr.y) > 0.2:
			array[i].y = (curr.y + prev.y + next.y) / 3

func get_ring_positions(layer):
	if layer == 0:
		return [ Vector3(0, get_noise(0, 0), 0) ]

	var array = []
	var corners = []

	# Add 6 corners
	var angle = START_ANGLE
	for _i in range(NB_CORNERS):
		corners.append(layer * Vector3(cos(angle), 0, -sin(angle)) * SCALE)
		angle -= CORNER_RADIUS

	# from each corner, compute middle points
	var size = corners.size()
	var pos
	for i in size:
		pos = corners[i]
		pos.y = get_noise(pos.x, pos.z)
		array.append(pos)
		var next = corners[0 if i + 1 >= size else (i + 1)]
		var dist = (next - corners[i]) / layer
		for j in range(1, layer):
			pos = corners[i] + j * dist
			pos.y = get_noise(pos.x, pos.z)
			array.append(pos)
	return array

func generate_vertexes(size):
	for i in range(size):
		vertexes.append_array(get_ring_positions(i))

func init_noise():
	noise = OpenSimplexNoise.new()
	var seedValue = floor(rand_range(0, 1000))
	noise.seed = seedValue
	noise.octaves = 9
	noise.period = MAP_PERIOD
	noise.persistence = MAP_PERSISTENCE

func init():
	init_noise()
	generate_vertexes(NB_RINGS)
	for i in range(1,5):
		flatten_world(vertexes)

func add_vertex(vertex):
	st.add_uv(Vector2(vertex.x, vertex.z))
	st.add_vertex(vertex)

func add_triangle(first, second, third):
	add_vertex(vertexes[first])
	add_vertex(vertexes[second])
	add_vertex(vertexes[third])

func generate_triangles_ring(level, root, start, nb_nodes):
	var base_root = root
	var value_max_nodes = start + nb_nodes
	for i in range(start, value_max_nodes, level):
		for j in range(0, level):
			var node1 = i + j
			var node2 = i + j + 1 if i + j + 1 <= value_max_nodes else start
			var node3 = root + j if root + j < start else base_root
			add_triangle(node1, node2, node3)
			if SPEED:
				yield(get_tree().create_timer(SPEED), "timeout")
			if j != level - 1:
				node1 = i + 1 + j
				node2 = root + j + 1 if root + j + 1 < start else base_root
				node3 = root + j
				add_triangle(node1, node2, node3)
				if SPEED:
					yield(get_tree().create_timer(SPEED), "timeout")
		root += level - 1
	if level == 1:
		add_triangle(6, 1, 0)

func generate_world():
	var level = 1
	var root = 0
	var start = 1
	var nb_nodes = 5
	for i in range(1, NB_RINGS):
		generate_triangles_ring(level, root, start, nb_nodes)
		level += 1
		root = start
		start += nb_nodes + 1
		nb_nodes += 6

func generate():
	if m:
		remove_child(m)
	m = MeshInstance.new()
	add_child(m)
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	generate_world()
	st.generate_normals()
	st.generate_tangents()
	m.mesh = st.commit()

func build_island():
	init()
	generate()

func _ready():
	build_island()

func _process(delta):
	get_input_keyboard(delta)

func get_input_keyboard(delta):
	if Input.is_action_pressed("generate"):
		vertexes.clear()
		build_island()

