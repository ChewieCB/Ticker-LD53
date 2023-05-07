@tool
extends Control

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
	title_text.text = generate_title_text(dialog)
	sub_title_text.text = generate_sub_title_text(dialog)
	body_text.text = dialog.body_text
	# Animate the dialog box
	animation_player.play("show_dialog")
	await animation_player.animation_finished
	await get_tree().create_timer(1.0).timeout
	hide_dialog()


func hide_dialog():
	# Animate the dialog box
	animation_player.play("hide_dialog")
