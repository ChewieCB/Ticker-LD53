extends Control

@onready var title_text = $MarginContainer/VBoxContainer/MarginContainer/TimerTextContainer/TextContainer/TimerText
@onready var time_text = $MarginContainer/VBoxContainer/TimerTimeContainer/TimeContainter/Time
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer


func _ready():
	add_to_group("ui/timer")
	set_timer(120)
	timer.start()


func _physics_process(_delta):
	time_text.text = update_time_display()


func set_timer(time):
	timer.wait_time = time


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
	get_tree().reload_current_scene()

