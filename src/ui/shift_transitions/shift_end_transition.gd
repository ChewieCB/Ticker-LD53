extends Control

signal count_finished
signal continue_pressed
signal next

@onready var animation_player = $AnimationPlayer
@onready var title = $MarginContainer/VBoxContainer/ScreenTitleContainer/ScreenTitle
@onready var earned_value = $MarginContainer/VBoxContainer/StatsMarginContainer/StatsBoxContainer/RightStatsContainer/VBoxContainer/EarnedValueContainer/EarnedValue
@onready var bills_value = $MarginContainer/VBoxContainer/StatsMarginContainer/StatsBoxContainer/RightStatsContainer/VBoxContainer/BillsValueContainer/BillsValue
@onready var profit_value = $MarginContainer/VBoxContainer/StatsMarginContainer/StatsBoxContainer/RightStatsContainer/VBoxContainer/ProfitValueContainer/ProfitValue
@onready var end_shift_button = $MarginContainer/VBoxContainer/ButtonContainer/CenterContainer/TextureButton

var shift_profit
var shift_profit_condition

var tick_earned: bool = false
var current_earned_value = 0
var tick_bills: bool = false
var current_bills_value = 0
var tick_profit: bool = false
var current_profit_value = 0
var shift_manager


func _ready():
	add_to_group("ui/transition/shift")
	await get_tree().root.get_child(get_tree().root.get_child_count()-1).ready
	shift_manager = get_tree().get_first_node_in_group("managers/shift")


func _input(event):
	if Input.is_action_just_pressed("interact"):
		next.emit()


func _physics_process(delta):
	if tick_earned:
		while tick_earned:
			while current_earned_value < PlayerManager.current_cash:
				current_earned_value += (delta * PlayerManager.current_cash * 0.3)
				earned_value.text = "[left]${0}[/left]".format([int(current_earned_value)])
				queue_redraw()
				await get_tree().process_frame
			tick_earned = false
			emit_signal("count_finished")
	if tick_bills:
		while tick_bills:
			while current_bills_value < shift_manager.shift.goal:
				current_bills_value += (delta * shift_manager.shift.goal * 0.3)
				bills_value.text = "[left]${0}[/left]".format([int(current_bills_value)])
				queue_redraw()
				await get_tree().process_frame
			tick_bills = false
			emit_signal("count_finished")
	if tick_profit:
		while tick_profit:
			if shift_profit > 0:
				while current_profit_value < shift_profit:
					current_profit_value += (delta * shift_profit * 0.3)
					profit_value.text = "[left]${0}[/left]".format([int(current_profit_value)])
					queue_redraw()
					await get_tree().process_frame
			else:
				while current_profit_value > shift_profit:
					current_profit_value += (delta * shift_profit * 0.3)
					profit_value.text = "[left]${0}[/left]".format([int(current_profit_value)])
					queue_redraw()
					await get_tree().process_frame
			tick_profit = false
			emit_signal("count_finished")


func start_shift():
	end_shift_button.disabled = true
	title.text = "[center]Day {0}[/center]".format([PlayerManager.current_day])
	animation_player.play("new_shift")
	await animation_player.animation_finished
	animation_player.play("new_shift_fade_title")


func end_shift():
	shift_profit = PlayerManager.current_cash - shift_manager.shift.goal
		
	title.text = "[center]Shift Over[/center]"
	animation_player.play("show_overlay")
	await animation_player.animation_finished
	
	animation_player.play("show_earned")
	await animation_player.animation_finished
	tick_earned = true
	await self.count_finished
	
	animation_player.play("show_bills")
	await animation_player.animation_finished
	tick_bills = true
	await self.count_finished
	
	animation_player.play("show_profit")
	await animation_player.animation_finished
	tick_profit = true
	await self.count_finished
	
	animation_player.play("show_button")
	await animation_player.animation_finished
	end_shift_button.disabled = false
	
	await self.next
	_on_ContinueButton_pressed()


func _on_ContinueButton_pressed():
	end_shift_button.disabled = true
	animation_player.play("fadeout")
	await animation_player.animation_finished
	emit_signal("continue_pressed")

