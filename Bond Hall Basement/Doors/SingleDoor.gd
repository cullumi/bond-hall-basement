extends Spatial

export (Material) var material setget set_material, get_material
export (float, 0, 100) var speed = 100
enum STATE {INWARD, CLOSED, OUTWARD}
export (STATE) var state = STATE.CLOSED setget set_state, get_state
export (bool) var debug = false# setget set_debug

onready var mesh = $DoorPivot/MeshInstance
onready var pivot = $DoorPivot
onready var anim_tree = $DoorPivot/AnimationTree
onready var anim_sm = anim_tree["parameters/playback"]

func _ready():
	if debug: set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_action_pressed("ui_right"):
		self.state = STATE.OUTWARD
	elif event.is_action_pressed("ui_left"):
		self.state = STATE.INWARD
	elif event.is_action_pressed("ui_down"):
		self.state = STATE.CLOSED

func open_inward():
	anim_sm.travel("open_inward_any")

func open_outward():
	anim_sm.travel("open_outward_any")

func close():
	anim_sm.travel("close_any")

func set_material(value): mesh["material/0"] = material
func get_material(): return mesh["material/0"]
func set_state(value): match value:
		STATE.INWARD: open_inward()
		STATE.CLOSED: close()
		STATE.OUTWARD: open_outward()
func get_state(): return STATE.INWARD if pivot.opened>0 else (STATE.OUTWARD if pivot.opened<0 else STATE.CLOSED)
#func set_debug(value):
#	debug = value
#	if debug: set_process_unhandled_input(true)
#	else: set_process_unhandled_input(false)
