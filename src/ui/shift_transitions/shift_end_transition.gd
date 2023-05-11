extends Control

signal shift_started
signal shift_finished
signal count_finished

@onready var animation_player = $AnimationPlayer
@onready var title = $MarginContainer/VBoxContainer/ScreenTitleContainer/ScreenTitle
@onready var earned_value = $MarginContainer/VBoxContainer/StatsMarginContainer/StatsBoxContainer/RightStatsContainer/VBoxContainer/EarnedValueContainer/EarnedValue
@onready var bills_value = $MarginContainer/VBoxContainer/StatsMarginContainer/StatsBoxContainer/RightStatsContainer/VBoxContainer/BillsValueContainer/BillsValue
@onready var profit_value = $MarginContainer/VBoxContainer/StatsMarginContainer/StatsBoxContainer/RightStatsContainer/VBoxContainer/ProfitValueContainer/ProfitValue
@onready var end_shift_button = $MarginContainer/VBoxContainer/ButtonContainer/CenterContainer/TextureButton

var tick_earned: bool = false
var current_earned_value = 0
var tick_bills: bool = false
var current_bills_value = 0
var tick_profit: bool = false
var current_profit_value = 0
@onready var temp_profit = PlayerManager.current_cash - 400


func _ready():
	add_to_group("ui/transition/end_shift")


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
			while current_bills_value < 400:
				current_bills_value += (delta * 400 * 0.3)
				bills_value.text = "[left]${0}[/left]".format([int(current_bills_value)])
				queue_redraw()
				await get_tree().process_frame
			tick_bills = false
			emit_signal("count_finished")
	if tick_profit:
		while tick_profit:
			while current_profit_value < temp_profit:
				current_profit_value += (delta * temp_profit * 0.3)
				profit_value.text = "[left]${0}[/left]".format([int(current_profit_value)])
				queue_redraw()
				await get_tree().process_frame
			tick_profit = false
			emit_signal("count_finished")


func start_shift():
	title.text = "[center]Day {0}[/center]".format([PlayerManager.current_day])
	animation_player.play("new_shift")
	await animation_player.animation_finished
	animation_player.play("new_shift_fade_title")
	get_tree().paused = false
	emit_signal("shift_started")


func end_shift():
	get_tree().paused = true
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


func _on_ContinueButton_pressed():
	animation_player.play("fadeout")
	await animation_player.animation_finished
	emit_signal("shift_finished")

