@tool
extends Control

enum DIALOG_TYPE {INFO, SUCCESS, FAIL}

@onready var portrait = $Portrait
@onready var icon = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/TitleContainer/Icon
@onready var title_text = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/TitleContainer/TitleContainer/TitleText
@onready var sub_title_text = $TextBox/VBoxContainer/HeadContainer/VBoxContainer/SubTitleContainer/SubTitleTextContainer/SubTitleText
@onready var body_text = $TextBox/VBoxContainer/Body/VBoxContainer/BodyContainer/BodyText

var dialog = Dialog:
	set(value):
		dialog = value
		portrait = dialog.portrait
		# TODO - icon
		title_text.text = generate_title_text(dialog)
		sub_title_text.text = generate_sub_title_text(dialog)
		body_text.text = dialog.body_text


func generate_title_text(dialog) -> String:
	var title_text_string = ""
	match dialog.type:
		DIALOG_TYPE.INFO:
			title_text_string = "[color=yellow]Incoming Message[/color]"
		DIALOG_TYPE.SUCCESS:
			title_text_string = "Delivery [color=green]Completed[/color]"
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
			sub_title_text_string = "[i][color={organ_color}]{organ_quality}%[/color] quality\n[color=yellow]$327[/color] reward[/i]".format(
				{"organ_color": organ_color, "organ_quality": dialog.organ_quality * 100}
			)
		DIALOG_TYPE.FAIL:
			var organ_color = get_organ_color(dialog.organ_quality, dialog.goal_organ_quality)
			sub_title_text_string = "[i][color={organ_color}]{organ_quality}%[/color] quality\n[color=yellow]$327[/color] reward[/i]".format(
				{"organ_color": organ_color, "organ_quality": dialog.organ_quality * 100}
			)
	return sub_title_text_string


func get_organ_color(organ_quality, goal_organ_quality):
	if organ_quality <= 1.0 and organ_quality >= goal_organ_quality:
		return "green"
	elif organ_quality < goal_organ_quality and organ_quality > goal_organ_quality - 25:
		return "orange"
	else:
		return "red"
