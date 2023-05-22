extends Node

const PICKUP_COLOR = Color("#02dced")
const DELIVERY_COLOR = Color("#02da88")
const SHOP_COLOR = Color("#fe86fc")

var organs: Array = []
var last_used_organ: Organ

var recipients: Array = []
var last_used_recipient: Recipient

@onready var delivery_zones: Array[Node] = get_tree().get_nodes_in_group("delivery_zones")
@onready var pickup_zones: Array[Node] = get_tree().get_nodes_in_group("pickup_zones")
#@onready var shop_zones: Array[Node] = get_tree().get_nodes_in_group("shop_zones")
var last_used_delivery_zone: DeliveryZone
var delivery_queue: Array[Delivery] = []

# Add a single fixed pickup spot for now, we can always extend this to add various pickup points
@export var pickup_location: DeliveryZone


func _ready() -> void:
	add_to_group("managers/delivery")
	# Load the resources
	organs = _load_resources("res://src/delivery/organs/resources/")
	recipients = _load_resources("res://src/characters/npcs/resources/")
	# Connect delivery zone signals
	for zone in delivery_zones:
		zone.activated.connect(complete_delivery)
	for zone in pickup_zones:
		zone.activated.connect(new_delivery)
	#
	await get_tree().root.get_child(get_tree().root.get_child_count()-1).ready
	var shift_manager = get_tree().get_first_node_in_group("managers/shift")
	shift_manager.shift_finished.connect(clear_delivery)

# TODO - move to utils v

func _load_resources(dir_path: String) -> Array:
	var loaded_resources = []
	var resource_files = DirAccess.get_files_at(dir_path)
	for resource in resource_files:
		# Prevents loader issues on export
		if resource.ends_with(".remap"):
			resource = resource.trim_suffix(".remap")
		var item = load(dir_path + resource)
		loaded_resources.append(item)
	
	return loaded_resources


func _random_non_repeat(full_array: Array, last_used_item = null):
	# Don't return the same item twice in a row
	var usable_items = [] + full_array
	if last_used_item:
		usable_items.erase(last_used_item)
	
	randomize()
	var new_item = usable_items[randi_range(0, usable_items.size() - 1)]
	
	return new_item

# TODO - move to utils ^


func new_delivery(pickup_zone: DeliveryZone = null) -> void:
	pickup_zone.is_active = false
	
	var _organ = next_organ()
	var _recipient = next_recipient()
#	var _pickup_location = next_zone()
	var delivery = generate_delivery(pickup_location, _organ, _recipient)
	delivery.organ_destroyed.connect(fail_delivery)
	update_delivery_queue(delivery)
	#
	get_tree().call_group("ui/organ", "set_delivery", delivery)


func complete_delivery(last_zone: DeliveryZone) -> void:
	last_zone.is_active = false
	var delivery = delivery_queue.pop_front()
	# Update dialog UI
	var completion_dialog = delivery.end_delivery()
	get_tree().call_group("ui/dialog", "new_dialog", completion_dialog)
	get_tree().call_group("ui/cash", "add_reward", delivery.reward * delivery.current_organ_quality)
	# Update last used values
	last_used_organ = delivery.organ
	last_used_recipient = delivery.recipient
	last_used_delivery_zone = delivery.drop_off_location
	# Get a new pickup location
	var new_pickup = next_pickup()
	new_pickup.is_active = true
	get_tree().call_group("ui/organ", "hide_status")
	


func fail_delivery() -> void:
	var delivery = delivery_queue.pop_front()
	delivery.drop_off_location.is_active = false
	# Update dialog UI
	var completion_dialog = Dialog.new()
	completion_dialog.type = Dialog.DIALOG_TYPE.FAIL
	completion_dialog.portrait = load("res://src/delivery/info_icons/flux.png")
	completion_dialog.body_text = "Organ destroyed, a fee of [color=red]${penalty}[/color] has been deducted.".format(
		{"penalty": delivery.organ.min_value}
	)
	get_tree().call_group("ui/dialog", "new_dialog", completion_dialog)
	get_tree().call_group("ui/cash", "add_reward", -delivery.organ.min_value)
	# Update last used values
	last_used_organ = delivery.organ
	last_used_recipient = delivery.recipient
	last_used_delivery_zone = delivery.drop_off_location
	# Get a new pickup location
	var new_pickup = next_pickup()
	new_pickup.is_active = true
	get_tree().call_group("ui/organ", "hide_status")


func clear_delivery() -> void:
	# Get a new pickup location
	var new_pickup = next_pickup()
	new_pickup.is_active = true
	#
	get_tree().call_group("ui/organ", "hide_status")
	get_tree().call_group("ui/organ", "set_delivery", null)


func update_delivery_queue(new_delivery) -> void:
	delivery_queue.push_back(new_delivery)
	# If the new delivery is first in the queue, start it
	if delivery_queue.find(new_delivery) == 0:
		new_delivery.start_delivery()


func generate_delivery(pickup_location: DeliveryZone, organ: Organ, recipient: Recipient) -> Delivery:
	# Generate a new delivery
	var delivery = Delivery.new()
	delivery.pickup_location = pickup_location
	delivery.drop_off_location = generate_drop_off(pickup_location)
	delivery.organ = organ
	# TODO - refine organ rewards
	delivery.reward = randi_range(organ.base_value - 30, organ.base_value + 30)
	delivery.recipient = recipient
	
	return delivery


func generate_drop_off(
		pickup_location: DeliveryZone, 
		min_distance: int = 32, max_distance: int = 128
	) -> DeliveryZone:
	# TODO - Pick a drop off location far enough away from the pickup, but not too far away
	return next_drop_off()


func next_organ() -> Organ:
	return _random_non_repeat(organs, last_used_organ)


func next_recipient() -> Recipient:
	return _random_non_repeat(recipients, last_used_recipient)


func next_drop_off() -> DeliveryZone:
	return _random_non_repeat(delivery_zones, last_used_delivery_zone)


func next_pickup() -> DeliveryZone:
	return _random_non_repeat(pickup_zones)
