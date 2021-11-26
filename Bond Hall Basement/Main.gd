extends Node

onready var controllers:ControllerManager = $Controllers

func _ready():
	controllers.activate()

func _unhandled_input(event):
	var quit = Input.is_action_just_pressed("quit")
	var left = Input.is_action_pressed("left_switch")
	var right = Input.is_action_pressed("right_switch")
	if left or right: 
		get_tree().set_input_as_handled()
		if left: controllers.switch_left()
		elif right: controllers.switch_right()
	elif quit:
		get_tree().quit()
