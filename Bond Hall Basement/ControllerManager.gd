extends Node

class_name ControllerManager

# Properties
var cons:Array = []
var current setget set_current, current
var cur_idx:int = -1 setget set_cur_idx, cur_idx

# Setters and Getters
func set_current(controller):
	current = controller
	cur_idx = cons.find(current)
func current():
	if not current: set_current(cons.front())
	return current
func set_cur_idx(idx:int):
	current = cons[idx]
	cur_idx = idx
func cur_idx():
	return cons.find(current())

# Initialization
func _ready():
	for child in get_children():
		if child.has_method("set_active"):
			child.set_active(false)
			cons.append(child)
	print("Controllers: ", cons)

# Switching
func switch_left(): switch_to((cur_idx()-1) % cons.size())
func switch_right(): switch_to((cur_idx()+1) % cons.size())

func switch_to(idx:int):
	deactivate()
	current = cons[idx % cons.size()]
	activate()
	print("Switched to: ", current, " (", cur_idx()+1, "/", cons.size(), ")")

func activate():
	if current(): current.set_active(true) #current.activate()
func deactivate():
	if current(): current.set_active(false) #current.deactivate()
