extends Spatial

export(NodePath) var BodyPath  = "" #You must specify this in the inspector!
export(NodePath) var PivotPath = ""
export(float) var MovementSpeed = 10
export(float) var Acceleration = 3
export(float) var MaxJump = 19
export(float) var MouseSensitivity = 2
export(float) var RotationLimit = 45
export(float) var MinZoom = 0.5
export(float) var MaxZoom = 1.5
export(float) var ZoomSpeed = 2
export(bool) var active = true setget set_active

enum {LM,RM,BM,FM,LT,RT,DT,UT,ZI,ZO,JU}
export(Dictionary) var actions = {
	LM:"left_move", RM:"right_move", BM:"back_move", FM:"forward_move",
	LT:"left_turn", RT:"right_turn", DT:"down_turn", UT:"up_turn",
	ZI:"zoom_in", ZO:"zoom_out", JU:"jump"
}
export(bool) var use_input_actions = true

onready var Body = get_node(BodyPath)
onready var Pivot = get_node(PivotPath)
onready var InnerGimbal = $InnerGimbal
onready var camera = $InnerGimbal/Camera
onready var zoomRay = $InnerGimbal/RayCast
var Direction = Vector3()
var Rot_Dir = Vector2()
var Rotation = Vector2()
var gravity = -10
var Movement = Vector3()
var ZoomFactor = 1
var ActualZoom = 1
var Speed = Vector3()
var CurrentVerticalSpeed = Vector3()
var JumpAcceleration = 3
var IsAirborne = false
onready var initial_zoom_ray_cast_to = zoomRay.cast_to

func set_active(value:bool):
	print("Controller set_active: ", value)
	active = value
	camera.current = value
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_input_as_handled()


# Inputs

func just_pressed(action:String) -> bool: return Input.is_action_just_pressed(action)
func just_released(action:String) -> bool: return Input.is_action_just_released(action)
func pressed(action:String) -> bool: return Input.is_action_pressed(action)

func _unhandled_input(event:InputEvent):
	if not active: return
	if event is InputEventMouseMotion: 
		Rotation = event.relative
	else:
		if (use_input_actions): action_input(event)
		else: raw_input(event)
	Direction.z = clamp(Direction.z, -1,1)
	Direction.x = clamp(Direction.x, -1,1)
	ZoomFactor = clamp(ZoomFactor, MinZoom, MaxZoom)
	Rotation += Rot_Dir * 2

func action_pressed(actions:Dictionary, event:InputEvent) -> int:
	for key in actions.keys():
		if event.is_action_pressed(actions[key]):
			return key
	return -1

func action_held(actions:Dictionary, event:InputEvent) -> int:
	for key in actions.keys():
		if event.is_action_pressed(actions[key], true):
			return key
	return -1

func action_released(action:Dictionary, event:InputEvent) -> int:
	for key in actions.keys():
		if event.is_action_released(actions[key]):
			return key
	return -1

func action_input(event:InputEvent):
#	print("Action Input")
	var action:int
	if event.is_pressed() and not event.is_echo():
		action = action_pressed(actions, event)
		if action < 0: return
		match action:
			LM: Direction.x -= 1
			RM: Direction.x += 1
			BM: Direction.z += 1
			FM: Direction.z -= 1
			LT: Rot_Dir.x += 1
			RT: Rot_Dir.x -= 1
			DT: Rot_Dir.y += 1
			UT: Rot_Dir.y -= 1
			ZI: ZoomFactor -= 0.05
			ZO: ZoomFactor += 0.05
			JU: jump()
	else:
		action = action_released(actions, event)
		if action < 0: return
		match action:
			LM: Direction.x += 1
			RM: Direction.x -= 1
			BM: Direction.z -= 1
			FM: Direction.z += 1
			LT: Rot_Dir.x -= 1
			RT: Rot_Dir.x += 1
			DT: Rot_Dir.y -= 1
			UT: Rot_Dir.y += 1

func raw_input(event):
#	print("Raw Input")
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_WHEEL_UP: ZoomFactor -= 0.05
			BUTTON_WHEEL_DOWN: ZoomFactor += 0.05
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_W: Direction.z -= 1
			KEY_S: Direction.z += 1
			KEY_A: Direction.x -= 1
			KEY_D: Direction.x += 1
	elif event is InputEventKey and not event.pressed:
		match event.scancode:
			KEY_W: Direction.z += 1
			KEY_S: Direction.z -= 1
			KEY_A: Direction.x += 1
			KEY_D: Direction.x -= 1
			KEY_SPACE: jump()


# Execution

func jump():
	if not IsAirborne:
		CurrentVerticalSpeed = Vector3(0,MaxJump,0)
		IsAirborne = true

func _physics_process(delta):
	if not active: return
	
	#Rotation
	Body.rotate_y(deg2rad(-Rotation.x)*delta*MouseSensitivity)
	InnerGimbal.rotate_x(deg2rad(-Rotation.y)*delta*MouseSensitivity)
	InnerGimbal.rotation_degrees.x = clamp(InnerGimbal.rotation_degrees.x, -RotationLimit, RotationLimit)
	Rotation = Vector2()
	
	#Movement
	var MaxSpeed = MovementSpeed *Direction.normalized()
	Speed = Speed.linear_interpolate(MaxSpeed, delta * Acceleration)
	Movement = Body.transform.basis * (Speed)
	CurrentVerticalSpeed.y += gravity * delta * JumpAcceleration
	Movement += CurrentVerticalSpeed
	Body.move_and_slide(Movement,Vector3(0,1,0))
	if Body.is_on_floor() :
		CurrentVerticalSpeed.y = 0
		IsAirborne = false
	
	#Zoom
	var ActualMaxZoom = max_zoom_from_ray()
	var ActualZoomFactor = min(ZoomFactor, ActualMaxZoom)
	ActualZoom = min(ActualZoom, ActualMaxZoom)
	ActualZoom = lerp(ActualZoom, ActualZoomFactor, delta * ZoomSpeed)
	InnerGimbal.set_scale(Vector3(ActualZoom,ActualZoom,ActualZoom))
	
	#Match Body Transform
	global_transform.origin = Pivot.global_transform.origin
	global_transform.basis = Pivot.global_transform.basis

func max_zoom_from_ray():
	if zoomRay.is_colliding():
		print("Colliding")
		zoomRay.cast_to = initial_zoom_ray_cast_to / ActualZoom
		var collPoint = zoomRay.to_local(zoomRay.get_collision_point()) * 0.9
		var castPoint = zoomRay.cast_to
		var ratio = collPoint.length() / castPoint.length()
		return MaxZoom * ratio
	else:
		print("Not Colliding")
	return MaxZoom

func min_vector(vector1, vector2):
	return vector1 if vector1.length() <= vector2.length() else vector2
