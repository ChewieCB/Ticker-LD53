extends Resource
class_name Shift

@export var time: int = 120
@export var goal: int = 1000
@export var intro_dialog: Dialog


func _init(
		p_time = 120, p_goal = 1000, p_intro_dialog = null
):
	time = p_time
	goal = p_goal
	intro_dialog = p_intro_dialog

