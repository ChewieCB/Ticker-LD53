@tool
extends Control

@onready var icon = $MarginContainer/TEMP_Icon
@onready var organ_name = $MarginContainer/MarginContainer/VBoxContainer/MarginContainer/OrganName
@onready var organ_health = $MarginContainer/MarginContainer/VBoxContainer/MarginContainer3/OrganHealth
@onready var animation_player = $AnimationPlayer

var delivery = Delivery:
	set = set_delivery


func _ready():
	add_to_group("ui/organ")


func hide_status():
	animation_player.play("hide_status")


func set_delivery(value):
	delivery = value
	icon.texture = delivery.organ.icon
	organ_name.text = delivery.organ.name
	organ_health.text = str(delivery.current_organ_quality)
	animation_player.play("show_status")

