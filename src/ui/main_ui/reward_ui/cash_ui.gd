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
	for idx in range(0, len(string), 3):
		if idx !=0:
			string = string.insert(len(string)-idx, ",")
	return "[center][color=yellow]{0}[/color][/center]".format([string])


func format_cash_diff_value(value: int) -> String:
	var string = str(value)
	for idx in range(0, len(string), 3):
		if idx !=0:
			string = string.insert(len(string)-idx, ",")
	return "[right][color=green]+${0}[/color][/right]".format([string])
