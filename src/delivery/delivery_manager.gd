extends Node2D

const PICKUP_COLOR = Color("#02dced")
const DELIVERY_COLOR = Color("#02da88")
const SHOP_COLOR = Color("#fe86fc")

var organs: Array[Organ] = []
var last_used_organ: Organ

var recipients: Array[Recipient] = []
var last_used_recipient: Recipient

var delivery_queue: Array[Delivery] = []

# Add a single fixed pickup spot for now, we can always extend this to add various pickup points
@export var pickup_location: Vector2


func _ready() -> void:
	# Load the resources
	organs = _load_resources("res://src/delivery/organs/resources/")
	recipients = _load_resources("res://src/characters/npcs/resources/")
	# Set the initial target for the first pickup
	new_delivery()

# TODO - move to utils v

func _load_resources(dir_path: String) -> Array:
	var loaded_resources = []
	var resource_files = DirAccess.get_files_at(dir_path)
	for resource in resource_files:
		var item = load(resource)
		loaded_resources.append(item)
	
	return loaded_resources


func _random_non_repeat(full_array: Array, last_used_item = null):
	# Don't return the same item twice in a row
	var usable_items = [] + full_array
	if last_used_item:
		usable_items.erase(last_used_item)
	
	randomize()
	var new_item = usable_items[randi_range(0, usable_items.size())]
	
	return new_item

# TODO - move to utils ^

func complete_delivery() -> void:
	var delivery = delivery_queue.pop_front()
	


func new_delivery() -> void:
	var _organ = next_organ()
	var _recipient = next_recipient()
	var delivery = generate_delivery(pickup_location, _organ, _recipient)
	delivery_queue.push_back(delivery)



func generate_delivery(pickup_location: Vector2, organ: Organ, recipient: Recipient) -> Delivery:
	# Generate a new delivery
	var delivery = Delivery.new()
	delivery.pickup_location = pickup_location
	delivery.drop_off_location = generate_drop_off(pickup_location)
	delivery.organ = organ
	delivery.reward = organ.base_value
	delivery.recipient = recipient
	
	return delivery


func generate_drop_off(
		pickup_location: Vector2, 
		min_distance: int = 32, max_distance: int = 128
	) -> Vector2:
	# Pick a drop off location far enough away from the pickup, but not too far away
	# TODO
	return Vector2()


func next_organ() -> Organ:
	return _random_non_repeat(organs, last_used_organ)


func next_recipient() -> Recipient:
	return _random_non_repeat(recipients, last_used_recipient)
