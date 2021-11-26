tool

extends Spatial

export (float, 0, 180) var full_open_angle = 145
export (float, -1, 1) var opened = 0 setget set_opened, get_opened

func set_opened(value):
	value = clamp(value, -1, 1)
	rotation_degrees.y = lerp(-full_open_angle, full_open_angle, (value+1)/2)
	Tool.delayed_plc_notify(self)
func get_opened(): return rotation_degrees.y / full_open_angle
