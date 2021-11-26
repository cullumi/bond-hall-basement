tool

extends Node

var tool_counter = ToolCounter.new()

func delayed_plc_notify(source=0):
	if !Engine.editor_hint || !is_inside_tree():
		return
	tool_counter.add(source)
	var run = tool_counter.count(source)
	yield(get_tree().create_timer(0.25), "timeout")
	if run == tool_counter.count(source):
		property_list_changed_notify()
		tool_counter.erase(source)
