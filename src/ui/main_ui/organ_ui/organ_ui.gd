@tool
extends Control

@onready var icon = $MarginContainer/MarginContainer/Organ
@onready var organ_name = $MarginContainer/MarginContainer/VBoxContainer/MarginContainer/OrganName
@onready var organ_health = $MarginContainer/MarginContainer/VBoxContainer/MarginContainer3/OrganHealth
@onready var animation_player = $AnimationPlayer

enum HEALTH_COLORS {HEALTHY, BRUISED, DAMAGED, RUPTURED, DESTROYED}
const health_text = ["Healthy", "Bruised", "Damaged", "Ruptured", "Ruined"]
const color_palettes = [
	# Healthy
	[
		Color("#168745"),
		Color("#00D170"),
		Color("#38FFBD")
	],
	# Bruised
	[
		Color("#7F671F"),
		Color("#C0A911"),
		Color("#EFEF48")
	],
	# Damaged
	[
		Color("#883616"),
		Color("#D15400"),
		Color("#FFA238")
	],
	# Ruptured
	[
		Color("#871623"),
		Color("#D10000"),
		Color("#FF5338")
	],
	# Destroyed
	[
		Color("#312439"),
		Color("#462B50"),
		Color("#704077")
	],
]

var delivery: Delivery:
	set = set_delivery


func _ready():
	add_to_group("ui/organ")


func hide_status():
	delivery = null
	animation_player.play("hide_status")


func damage_organ(speed: float):
	if delivery:
		if delivery.current_organ_quality > 0:
			animation_player.play("shake")
			var damage = speed / delivery.organ.fragility / 1500
			delivery.current_organ_quality -= damage
			update_organ_ui()
		else:
			animation_player.play("shake_no_flash")


func update_organ_ui():
		var organ_health_idx = get_organ_health_map(delivery.current_organ_quality)
		var organ_palette = color_palettes[organ_health_idx]
		swap_palette(organ_palette)
		organ_name.text = "[center][color=#{0}]{1}[/color][/center]".format([
			get_color_hex(organ_palette[2]),
			delivery.organ.name
		])
		organ_health.text = "[center][color=#{0}]{1}[/color][/center]".format([
			get_color_hex(organ_palette[2]),
			health_text[organ_health_idx]
		])


func get_organ_health_map(health: float) -> HEALTH_COLORS:
	if health > 0.75:
		return HEALTH_COLORS.HEALTHY
	elif health < 0.75 and health > 0.5:
		return HEALTH_COLORS.BRUISED
	elif health < 0.5 and health > 0.25:
		return HEALTH_COLORS.DAMAGED
	elif health < 0.25 and health > 0:
		return HEALTH_COLORS.RUPTURED
	else:
		return HEALTH_COLORS.DESTROYED


func convert_to_hex(value) -> String:
	const hex_table = "0123456789ABCDEF"
	return hex_table[
		int(value / 16)] + hex_table[((float(value) / 16) - int(value / 16)) * 16
	]

func get_color_hex(color: Color) -> String:
	return convert_to_hex(color.r8) + convert_to_hex(color.g8) + convert_to_hex(color.b8)


func swap_palette(new_color_palette):
	for i in range(0, 3):
		icon.material.set_shader_parameter("replace_{0}".format([i]), new_color_palette[i])


func set_delivery(value):
	delivery = value
	if delivery:
		icon.texture = delivery.organ.icon
		update_organ_ui()
		animation_player.play("show_status")

