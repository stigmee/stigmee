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
const NB_RINGS = 50
const SCALE = 3

const SPEED = 0

const MAP_INTENSITY = 20 # height of mountains
const MAP_PERIOD = 100 # size of mountains
const MAP_PERSISTENCE = 0.5 # 0.1 = smooth, 1 = not smooth
const ISLAND_SIZE = 200

var noise

var st
var vertexes = []
var m

const RIVER_CIRCLES = []
const RIVER_LENGTH = 150
const RIVER_RADIUS = 3
const RIVER_AMPLITUDE_Y = 4

func generate_river(size, radius):
	RIVER_CIRCLES.clear()
	var half_size = size / 2
	var x = -half_size + 10
	var r = radius
	while x < half_size:
		var pos2 = Vector2(x,0)
		RIVER_CIRCLES.append({ pos=pos2, radius=r })
		x += r / 2

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
		var pos = Vector2(vertex.x,vertex.z)
		vertex.y = (noise.get_noise_3d(vertex.x, vertex.y, vertex.z)+0.5) * MAP_INTENSITY
		var found = false
		if vertex.z >= -5 and vertex.z <= 5:
			vertex.y -= 2
		for circ in RIVER_CIRCLES:
			if not found and pos.distance_to(circ.pos) < circ.radius:
				found = true
				circ.realPos = vertex

		data_tool.set_vertex(i, vertex)
	
	for i in range(array_plane.get_surface_count()):
		array_plane.surface_remove(i)

	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	get_parent().get_node("GeneratedStrand").mesh = surface_tool.commit()

func init():
	generate_river(RIVER_LENGTH, RIVER_RADIUS)
	generate()

func get_river():
	return RIVER_CIRCLES
