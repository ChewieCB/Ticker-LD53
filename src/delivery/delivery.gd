extends Resource
class_name Delivery

var pickup_location: DeliveryZone
var drop_off_location: DeliveryZone
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
		p_pickup_location = null, p_drop_off_location = null, p_organ = null, 
		p_organ_starting_quality = randf_range(0.75, 1), p_organ_goal_quality = 0.5, p_organ_degredation_rate = 0.0,
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
	drop_off_location.is_active = true
	current_organ_quality = organ_starting_quality
	# TODO - tick down organ quality
	pass


func end_delivery() -> Dialog:
	randomize()
	# Generate dialog
	var dialog = Dialog.new()
	dialog.portrait = recipient.portrait
	if current_organ_quality > organ_goal_quality - 25:
		dialog.type = Dialog.DIALOG_TYPE.SUCCESS
	else:
		dialog.type = Dialog.DIALOG_TYPE.FAIL
	# TODO - factor these values in instead of randomising them
	dialog.reward = reward * current_organ_quality
	dialog.organ_quality = current_organ_quality
	dialog.goal_organ_quality = organ_goal_quality
	# TODO - factor this text to depend on delivery quality/status
	var possible_text = organ.successful_delivery_text
	dialog.body_text = possible_text[randi_range(0, possible_text.size() - 1)]
	
	return dialog
	# TODO - handle rewards


func take_damage(amount: float):
	current_organ_quality -= amount

