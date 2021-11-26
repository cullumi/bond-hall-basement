extends Spatial

class_name RoomCam

# Status
export(bool) var active = false setget set_active

# Constraints
export (Vector2) var turn_radii = Vector2(35,45)
export (float) var turn_speed = 100
var turn_offset = Vector2()

# Nodes
onready var pitch = $Pitch
onready var camera = $"Pitch/Camera"
var current = false setget set_current, get_current
func set_current(value): camera.current = value
func get_current(): return camera.current

# Activation

func set_active(value:bool):
	active = value
	self.current = value
	if value: get_tree().set_input_as_handled()

# Inputs
func _unhandled_input(event):
	if not active: return
	var left = Input.is_action_pressed("left_turn")
	var right = Input.is_action_pressed("right_turn")
	var down = Input.is_action_pressed("down_turn")
	var up = Input.is_action_pressed("up_turn")
	if left: turn_camera_yaw(turn_speed)
	elif right: turn_camera_yaw(-turn_speed)
	elif down: turn_camera_pitch(-turn_speed)
	elif up: turn_camera_pitch(turn_speed)
	if left or right or down or up: get_tree().set_input_as_handled()

# Camera Turning
func turn_camera_yaw(rate:float):
	var change = -rate*get_process_delta_time()
	change = clamp_rotation(turn_offset.y, change, turn_radii.y)
	turn_offset.y += change
	rotate_y(deg2rad(change))

func turn_camera_pitch(rate:float):
	var change = rate*get_process_delta_time()
	change = clamp_rotation(turn_offset.x, change, turn_radii.x)
	turn_offset.x += change
	pitch.rotate_x(deg2rad(change))

func clamp_rotation(angle:float, change:float, radius:float) -> float:
	var result = angle + change
	var clamped = clamp(result, -radius, radius)
	if result != clamped:
		change += clamped - result
	return change
