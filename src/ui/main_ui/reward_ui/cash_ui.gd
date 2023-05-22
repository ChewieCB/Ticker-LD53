extends Control

@onready var cash_text = $MarginContainer/VBoxContainer/CashContainer/HBoxContainer/CashContainter/Cash
@onready var cash_changed_text = $MarginContainer/VBoxContainer/CashChangeContainer/CashChange
@onready var animation_player = $AnimationPlayer


func _ready():
	add_to_group("ui/cash")
	cash_text.text = format_cash_value(PlayerManager.current_cash)
	animation_player.play("default")


func add_reward(value: int):
	PlayerManager.current_cash += value
	cash_text.text = format_cash_value(PlayerManager.current_cash)
	cash_changed_text.text = format_cash_diff_value(value)
	animation_player.play("add_reward")


func format_cash_value(value: int) -> String:
	var string = str(value)
	var comma_digit = 3
	var is_negative = string.begins_with("-")
	# Don't add a comma before the minus for negative numbers
	if is_negative:
		string = string.trim_prefix("-")
	for idx in range(0, len(string), 3):
		if idx !=0:
			string = string.insert(len(string)-idx, ",")
	# Add the minus back in
	if is_negative:
		# FIXME - not adding minus
		string = string.insert(0, "-")
	return "[center][color=yellow]{0}[/color][/center]".format([string])


func format_cash_diff_value(value: int) -> String:
	var string = str(value)
	var is_negative = string.begins_with("-")
	var sign = "-" if is_negative else "+"
	if is_negative:
		string = string.trim_prefix("-")
	for idx in range(0, len(string), 3):
		if idx !=0:
			string = string.insert(len(string)-idx, ",")
	return "[right][color=green]{0}${1}[/color][/right]".format([sign, string])
