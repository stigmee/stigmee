###############################################################################
# This code is a portage to Godot code from the Unity3D code made by the
# Youtube channel Game Dev Guide. Please watch this video:
# https://youtu.be/rnqF6S7PfFA
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
# Setting to tune from the editor GUI
# ==============================================================================
export(float) var movementTime = 5.0
export(float) var normalSpeed = 0.1
export(float) var fastSpeed = 1.0
export(float) var normalZoomAmount = 0.1
export(float) var fastZoomAmount = 1.0
export(float) var rotationAmount = 3.0

# Follow an 3D object in the world
var tracking: Spatial = null
var tracking_offset: Vector3 = Vector3.ZERO

# Desired transformation matrix
var newPosition: Vector3
var newRotation: Quat
var newZoom: float = 0.0
var newFov: float

# Fake world plane to intersect the ray "camera --> mouse cursor".
var plane = Plane(Vector3.UP, 0.0)

# Delta mouse displacement and delta mouse rotation
var dragStartPosition: Vector3
var dragCurrentPosition: Vector3
var rotateStartPosition: Vector2
var rotateCurrentPosition: Vector2

# Mouse left/right mouse button pressed: up, down, falling edge, rising edge
var left_prev_pressed: bool = false
var left_pressed: bool = false
var right_prev_pressed: bool = false
var right_pressed: bool = false

# Temporary quaternion
var q: Quat

# ==============================================================================
# A child node Camera shall exists
# ==============================================================================
onready var movementSpeed: float = normalSpeed
onready var zoomAmount: float = normalZoomAmount
func _ready():
	newPosition = self.transform.origin
	newRotation = Quat(self.transform.basis)
	newFov = $Camera.fov
	pass

# ==============================================================================
# SHIFT key pressed event and mouse scrolled event
# ==============================================================================
func _input(event):
	# Stop controlling the camera when, for example, the CEF page is opened
	if not Global.enable_orbit_camera:
		return
	
	# Mouse "scrolled" event: modify the camera zoom
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			newFov += zoomAmount
		if event.button_index == BUTTON_WHEEL_DOWN:
			newFov -= zoomAmount
		newFov = clamp(newFov, 1.0, 179.0)

	# Faster displacements when the SHIFT key is pressed
	if event is InputEventKey:
		if event.shift:
			movementSpeed = fastSpeed
			zoomAmount = fastZoomAmount
		else:
			movementSpeed = normalSpeed
			zoomAmount = normalZoomAmount
	pass

# ==============================================================================
# Compute the reference transformation matrix for the camera through mouse
# actions:
#   - mouse scroll: Field of view.
#   - left pressed button: translate the camera.
#   - right pressed button: rotate the camera.
# ==============================================================================
func handle_mouse_actions(dt):
	# Mouse left button "on pressed" and "pressed" event: translate the camera.
	# Get the intersection point between the ray "camera ==> mouse cursor"
	# and the world plane. Rotate the camera of the difference of position
	# between the initial intersection position when the mouse left button
	# was pressed and the current intersection position.
	left_prev_pressed = left_pressed
	right_prev_pressed = right_pressed
	left_pressed = Input.is_mouse_button_pressed(BUTTON_LEFT)
	if left_pressed:
		var camera = $Camera
		# Get the current mouse position in the screen (camera's viewport)
		var mouse_pos = get_viewport().get_mouse_position()
		# Origin point of the ray
		var start = camera.project_ray_origin(mouse_pos)
		# Destination point of the ray
		var end = start + camera.project_ray_normal(mouse_pos) * camera.get_zfar()
		# Ray hit the world plane ?
		var intersection = plane.intersects_ray(start, end)
		# Rotate the camera if intersection happens (always true !?)
		if intersection != null:
			if (not left_prev_pressed) and left_pressed:
				dragStartPosition = intersection
			dragCurrentPosition = intersection
			newPosition = self.transform.origin + dragStartPosition - dragCurrentPosition

	# Mouse right button "on pressed" and "pressed" event: rotate the camera.
	right_pressed = Input.is_mouse_button_pressed(BUTTON_RIGHT)
	if right_pressed:
		if not right_prev_pressed:
			rotateStartPosition = get_viewport().get_mouse_position()
		rotateCurrentPosition = get_viewport().get_mouse_position()
		var diff: Vector2 = rotateStartPosition - rotateCurrentPosition
		rotateStartPosition = rotateCurrentPosition
		q.set_euler(Vector3.UP * diff.x / 5.0 * dt)
		newRotation *= q
		q.set_euler(Vector3.RIGHT * diff.y / 5.0 * dt)
		newRotation *= q
	pass

# ==============================================================================
# Compute the reference transformation matrix for the camera through mouse
# actions:
#   - directional keys: translate the camera
#   - W, S, D, A: translate the camera
#   - O, I: camera rotation
#   - R, F: zoom
# ==============================================================================
func handle_keyboard_actions(dt):
	# Translate the camera long one of X-Y-Z axis
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		newPosition += (transform.basis.z * -movementSpeed * dt)
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		newPosition += (transform.basis.z * movementSpeed * dt)
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		newPosition += (transform.basis.x * movementSpeed * dt)
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		newPosition += (transform.basis.x * -movementSpeed * dt)
	# Camera zoom
	if Input.is_key_pressed(KEY_R):
		newZoom += zoomAmount
	if Input.is_key_pressed(KEY_F):
		newZoom -= zoomAmount
	# Camera rotation
	if Input.is_key_pressed(KEY_O):
		q.set_euler(Vector3.UP * rotationAmount * dt)
		newRotation *= q
	if Input.is_key_pressed(KEY_I):
		q.set_euler(Vector3.UP * -rotationAmount * dt)
		newRotation *= q
	pass

# ==============================================================================
# Make the camera tracks (follows) the position of a 3D object inside the
# world. This can be used for example to reach the browser node when typing
# its name in a search entry widget.
# We only need to access to the transform field of the tracked object but
# since Godot passes them by value we can use them directly. Therefore we
# directly hold Spatial ... since Godot passes it by reference.
# ==============================================================================
func track(object: Spatial):
	tracking = object
	# FIXME tracking_offset could be removed if I know how to extract the local
	# translation
	tracking_offset = transform.origin - tracking.transform.origin
	pass

# ==============================================================================
# Update the camera transformation matrix either from mouse and keyboard actions
# or by following another 3D object in the scene.
# ==============================================================================
func _process(dt):
	# Stop controlling the camera when, for example, the CEF page is opened
	if not Global.enable_orbit_camera:
		return

	# Is the camera tracking (following) the position of a 3D object inside the
	# world ?
	if tracking == null:
		# Control the camera with the mouse and keyboard actions
		handle_mouse_actions(dt)
		handle_keyboard_actions(dt)
	else:
		# If yes, press ESCAPE to untrack it, else if the object is moving
		# the camera will follow it.
		if Input.is_key_pressed(KEY_ESCAPE):
			tracking = null
		else:
			# Follow the object position.
			newPosition = tracking.transform.origin + tracking_offset

	# Displace the camera with smooth transitions.
	# FIXME: I used the bad usage of lerp because for the moment it is fine but
	# lerp(origin, destination, ratio) shall have static (over time) parameters
	# 'origin' and 'destination' and dynamic parameter 'ratio' going from 0 to 1.
	# https://gamedevbeginner.com/the-right-way-to-lerp-in-unity-with-examples
	var w = 1.0 - exp(-movementTime * dt)
	transform.origin = lerp(transform.origin, newPosition, w)
	transform.basis = Basis(newRotation.slerp(Quat(transform.basis), w))
	$Camera.transform.origin = lerp($Camera.transform.origin, Vector3.ONE * newZoom, w)
	$Camera.fov = lerp($Camera.fov, newFov, w)
	pass
