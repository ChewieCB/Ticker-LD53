@tool
extends Control

signal finished
signal next

enum DIALOG_TYPE {INFO, SUCCESS, FAIL}

@onready var portrait = $Portrait
@onready var icon = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/TitleContainer/Icon
@onready var title_text = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/TitleContainer/TitleContainer/TitleText
@onready var sub_title_text = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/SubTitleContainer/SubTitleTextContainer/SubTitleText
@onready var body_text = $TextBox/VBoxContainer/Body/VBoxContainer/BodyContainer/BodyText
@onready var animation_player = $AnimationPlayer

var autofade_timer
var dialog = Dialog:
	set = set_dialog


func _ready():
	add_to_group("ui/dialog")


func _input(event):
	if Input.is_action_just_pressed("interact"):
		_next()


func generate_title_text(dialog) -> String:
	var title_text_string = ""
	match dialog.type:
		DIALOG_TYPE.INFO:
			title_text_string = "[color=yellow]Incoming Message[/color]"
		DIALOG_TYPE.SUCCESS:
			title_text_string = "Delivery [color=green]Complete[/color]"
		DIALOG_TYPE.FAIL:
			title_text_string = "Delivery [color=red]Failed[/color]"
	return title_text_string


func generate_sub_title_text(dialog) -> String:
	var sub_title_text_string = ""
	match dialog.type:
		DIALOG_TYPE.INFO:
			sub_title_text_string = "[color=red]Unknown Sender[/color]"
		DIALOG_TYPE.SUCCESS:
			var organ_color = get_organ_color(dialog.organ_quality, dialog.goal_organ_quality)
			sub_title_text_string = "[i][color={organ_color}]{organ_quality}%[/color] quality\n[color=yellow]${reward}[/color] reward[/i]".format(
				{"organ_color": organ_color, "organ_quality": roundi(dialog.organ_quality * 100), "reward": dialog.reward}
			)
		DIALOG_TYPE.FAIL:
			var organ_color = get_organ_color(dialog.organ_quality, dialog.goal_organ_quality)
			sub_title_text_string = "[i][color={organ_color}]{organ_quality}%[/color] quality\n[color=yellow]${reward}[/color] reward[/i]".format(
				{"organ_color": organ_color, "organ_quality": roundi(dialog.organ_quality * 100), "reward": dialog.reward}
			)
	return sub_title_text_string


func get_organ_color(organ_quality, goal_organ_quality):
	if organ_quality > 0.75:
		return "green"
	elif organ_quality < 0.75 and organ_quality > 0.5:
		return "yellow"
	elif organ_quality < 0.5 and organ_quality > 0.25:
		return "orange"
	else:
		return "red"


func set_dialog(value):
	# Set dialog box content
	dialog = value
	portrait.texture = dialog.portrait
	match dialog.type:
		Dialog.DIALOG_TYPE.INFO:
			icon.texture = load("res://src/ui/main_ui/dialog_box/info.png")
		Dialog.DIALOG_TYPE.SUCCESS:
			icon.texture = load("res://src/ui/main_ui/dialog_box/success.png")
		Dialog.DIALOG_TYPE.FAIL:
			icon.texture = load("res://src/ui/main_ui/dialog_box/failure.png")
	match dialog.head_text:
		"":
			title_text.text = generate_title_text(dialog)
		_:
			title_text.text= dialog.head_text
	match dialog.subhead_text:
		"":
			sub_title_text.text = generate_sub_title_text(dialog)
		_:
			sub_title_text.text = dialog.subhead_text
	body_text.text = dialog.body_text


func new_dialog(dialog: Dialog):
	# Handle if the dialog box pauses the game
	if dialog.is_paused:
		get_tree().paused = true
	
	# Update the dialog
	set_dialog(dialog)
	
	# Animate the dialog box
	animation_player.play("show_dialog")
	await animation_player.animation_finished
	if dialog.linked_dialog:
		animation_player.play("show_next")
		await animation_player.animation_finished
		animation_player.play("wait_next")
	
	# Wait for user input/timer to continue
	continue_dialog()


func continue_dialog():
	# Wait for user input or auto-fade timer to continue
	if dialog.auto_fade:
		autofade_timer = get_tree().create_timer(dialog.auto_fade_after)
		autofade_timer.timeout.connect(_next)
	await self.next
	
	# Handle Linked/Chained Dialog's
	if dialog.linked_dialog:
		next_dialog()
	else:
		end_dialog()


func next_dialog():
	# Hide the previous dialog
	animation_player.play("chain_dialog_1")
	await animation_player.animation_finished
	# Update the dialog
	set_dialog(dialog.linked_dialog)
	# Show the new dialog
	animation_player.play("chain_dialog_2")
	await animation_player.animation_finished
	
	if dialog.linked_dialog:
		animation_player.play("show_next")
		await animation_player.animation_finished
		animation_player.play("wait_next")
	
	# Wait for user input/timer to continue
	continue_dialog()


func end_dialog():
	if dialog.is_paused:
		get_tree().paused = false
	finished.emit()
	animation_player.play("hide_dialog")
	await animation_player.animation_finished


func _next():
	# Helper method so we can trigger the next signal via timer
	if autofade_timer:
		if autofade_timer.time_left > 0 and autofade_timer.timeout.is_connected(_next):
			autofade_timer.timeout.disconnect(_next)
	next.emit()
