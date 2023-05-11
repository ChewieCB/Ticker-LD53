extends Control

@onready var title_text = $MarginContainer/VBoxContainer/MarginContainer/TimerTextContainer/TextContainer/TimerText
@onready var time_text = $MarginContainer/VBoxContainer/TimerTimeContainer/TimeContainter/Time
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

@export var start_time: int = 120


func _ready():
	add_to_group("ui/timer")
	set_timer(start_time)


func _physics_process(_delta):
	time_text.text = update_time_display()


func set_timer(time):
	timer.wait_time = time


func start_timer():
	timer.start()


func update_time_display() -> String:
	var timer_minutes = (int(timer.time_left) % 3600) / 60
	var timer_seconds = int(timer.time_left) % 60
	var time_string = "[center]{minutes}:{seconds}[/center]".format(
		{
			"minutes": "%01d" % timer_minutes,
			"seconds": "%02d" % timer_seconds
		}
	)
	return time_string


func _on_timer_timeout():
	# Scene Transition
	var shift_transition_ui = get_tree().get_first_node_in_group("ui/transition/end_shift")
	shift_transition_ui.end_shift()
	await shift_transition_ui.shift_finished
	PlayerManager.current_day += 1
	get_tree().reload_current_scene()

