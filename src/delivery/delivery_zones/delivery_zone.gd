@tool
extends Node2D
class_name DeliveryZone

signal activated(zone)

enum ZONE_TYPE {DROP_OFF, PICK_UP, SHOP}
const zone_colors: Array[Color] = [Color("#02da88"), Color("#02dced"), Color("#fe86fc")]

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite

@export var zone_type: ZONE_TYPE

@onready var is_active: bool = false:
	set(value):
		is_active = value
		# Handle animations
		if is_active:
			animation_player.play("DeliveryZone/fade_in")
			await animation_player.animation_finished
			animation_player.play("DeliveryZone/glow")
		else:
			animation_player.play("DeliveryZone/fade_out")
			can_deliver = false

var can_deliver: bool = false
var player_ref: Player


func _ready():
	if not Engine.is_editor_hint():
		animation_player.play("DeliveryZone/hidden")
	#
	sprite.modulate = zone_colors[zone_type]
	match zone_type:
		ZONE_TYPE.DROP_OFF:
			add_to_group("delivery_zones")
		ZONE_TYPE.PICK_UP:
			add_to_group("pickup_zones")
			is_active = true
		ZONE_TYPE.SHOP:
				add_to_group("shop_zones")


func _physics_process(_delta):
	if can_deliver:
		if player_ref.velocity.length() < 20:
			activated.emit(self)


func _on_Area_body_entered(body):
	if is_active and body is Player:
		player_ref = body
		can_deliver = true


func _on_Area_body_exited(body):
	if is_active and body is Player:
		can_deliver = false
