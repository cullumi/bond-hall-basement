extends Object

class_name ToolCounter

const editor_runs:Dictionary = {}

func add(source):
	if not editor_runs.has(source):
		editor_runs[source] = 0
	editor_runs[source] += 1

func count(source) -> int:
	if not editor_runs.has(source):
		return 0
	return editor_runs[source]

func erase(source) -> bool:
	return editor_runs.erase(source)
