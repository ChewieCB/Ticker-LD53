extends Node

signal shift_started
signal shift_finished

@export var shift_array: Array[Shift]
var shift: Shift

var shift_transition_ui: Control
var shift_timer: Control


func _ready():
	# 
	await get_tree().root.get_child(get_tree().root.get_child_count()-1).ready
	shift_transition_ui = get_tree().get_first_node_in_group("ui/transition/shift")
	shift_timer = get_tree().get_first_node_in_group("ui/timer")
	start_shift()


func start_shift():
	shift = shift_array.pop_front()
	
	shift_timer.set_timer(shift.time)
	shift_transition_ui.start_shift()
	
	# Trigger the initial cutscene messages
	if shift.intro_dialog:
		var dialog_ui = get_tree().get_first_node_in_group("ui/dialog")
		dialog_ui.new_dialog(shift.intro_dialog)
		await dialog_ui.finished
	
	get_tree().paused = false
	emit_signal("shift_started")


func end_shift():
	get_tree().paused = true
	shift_transition_ui.end_shift()
	await shift_transition_ui.continue_pressed
	PlayerManager.current_day += 1
	PlayerManager.current_cash -= shift.goal
	start_shift()
