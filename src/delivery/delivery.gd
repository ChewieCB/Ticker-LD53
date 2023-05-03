extends Resource
class_name Delivery

var pickup_location: Vector2
var drop_off_location: Vector2
var organ: Organ
var organ_starting_quality: float
var current_organ_quality: float :
	set(value):
		current_organ_quality = clamp(value, 0, 1)
var organ_goal_quality: float
var organ_degredation_rate: float
var reward: int
var recipient: Recipient


func _init(
		p_pickup_location = Vector2(), p_drop_off_location = Vector2(), p_organ = null, 
		p_organ_starting_quality = 1.0, p_organ_goal_quality = 0.5, p_organ_degredation_rate = 0.0,
		p_reward = 0, p_recipient = null
	):
	pickup_location = p_pickup_location
	drop_off_location = p_drop_off_location
	organ = p_organ
	organ_starting_quality = p_organ_starting_quality
	organ_goal_quality = p_organ_goal_quality
	organ_degredation_rate = p_organ_degredation_rate
	reward = p_reward
	recipient = p_recipient


func start_delivery() -> void:
	current_organ_quality = organ_starting_quality
	# TODO - tick down organ quality
	pass


func end_delivery() -> void:
	# TODO
	pass


func take_damage(amount: float):
	current_organ_quality -= amount

