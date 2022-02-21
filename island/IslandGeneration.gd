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

const MAP_INTENSITY = 50 # height of mountains
const MAP_PERIOD = 150 # size of mountains
const MAP_PERSISTENCE = 0.5 # 0.1 = smooth, 1 = not smooth
const ISLAND_SIZE = 200

var DEFAULT_ZOOM = 5
var is_open = false

func load_scene():
	build_island()
	$Interface/StrandList.init()

func open_scene(_data):
	is_open = true
	self.visible = true
	for child in get_children():
		child.visible = true
	get_parent().get_node("OrbitCamera").set_zoom(DEFAULT_ZOOM)

func close_scene():
	is_open = false
	self.visible = false
	for child in get_children():
		child.visible = false

func gradientAtPos(pos):
	return pos.length() / (ISLAND_SIZE * sqrt(2))

func generate():
	var noise = OpenSimplexNoise.new()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var seedValue = rng.randi_range(0, 1000)
	noise.seed = seedValue
	noise.period = MAP_PERIOD
	noise.octaves = 6
	noise.persistence = MAP_PERSISTENCE
	
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2.ONE * ISLAND_SIZE
	plane_mesh.subdivide_depth = 150
	plane_mesh.subdivide_width = 150
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)
	
	var array_plane = surface_tool.commit()
	
	var data_tool = MeshDataTool.new()
	data_tool.create_from_surface(array_plane, 0)

	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		var noiseValue = noise.get_noise_3d(vertex.x, vertex.y, vertex.z)
		vertex.y = (noiseValue - gradientAtPos(vertex)) * MAP_INTENSITY
		
		data_tool.set_vertex(i, vertex)
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)
	
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	$GeneratedIsland.mesh = surface_tool.commit()

func build_island():
	generate()
