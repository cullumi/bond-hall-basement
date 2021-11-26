extends Spatial

export (bool) var active setget set_active

onready var controller = $Controller

func set_active(val:bool):
	controller.set_active(val)
