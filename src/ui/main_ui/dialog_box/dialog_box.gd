@tool
extends Control

signal finished

enum DIALOG_TYPE {INFO, SUCCESS, FAIL}

@onready var portrait = $Portrait
@onready var icon = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/TitleContainer/Icon
@onready var title_text = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/TitleContainer/TitleContainer/TitleText
@onready var sub_title_text = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/SubTitleContainer/SubTitleTextContainer/SubTitleText
@onready var body_text = $TextBox/VBoxContainer/Body/VBoxContainer/BodyContainer/BodyText
@onready var animation_player = $AnimationPlayer

var dialog = Dialog:
	set = set_dialog


func _ready():
	add_to_group("ui/dialog")


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
			sub_title_text_string = "[color=yellow]Incoming Message[/color]"
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
	elif organ_quality < 0.75:
		return "yellow"
	elif organ_quality < 0.5 and organ_quality > 0.25:
		return "orange"
	else:
		return "red"


func set_dialog(value):
	dialog = value
	portrait.texture = dialog.portrait
	# TODO - icon
	match dialog.type:
		Dialog.DIALOG_TYPE.INFO:
			icon.texture = load("res://src/ui/main_ui/dialog_box/info.png")
		Dialog.DIALOG_TYPE.SUCCESS:
			icon.texture = load("res://src/ui/main_ui/dialog_box/success.png")
		Dialog.DIALOG_TYPE.FAIL:
			icon.texture = load("res://src/ui/main_ui/dialog_box/failure.png")
	
	if dialog.head_text == "":
		title_text.text = generate_title_text(dialog)
	if dialog.subhead_text == "":
		sub_title_text.text = generate_sub_title_text(dialog)
	body_text.text = dialog.body_text
	# Handle if the dialog box pauses the game
	if dialog.is_paused:
		get_tree().paused = true
	# Animate the dialog box
	animation_player.play("show_dialog")
	await animation_player.animation_finished
	if dialog.linked_dialog:
		animation_player.play("show_next")
		await animation_player.animation_finished
		animation_player.play("wait_next")
	if dialog.auto_fade:
		await get_tree().create_timer(dialog.auto_fade_after).timeout
		hide_dialog()
		if dialog.is_paused:
			get_tree().paused = false


func hide_dialog():
	if dialog.linked_dialog:
		animation_player.play("hide_next")
	# Animate the dialog box
	animation_player.play("hide_dialog")
	if dialog.linked_dialog:
		set_dialog(dialog.linked_dialog)
	else:
		finished.emit()
