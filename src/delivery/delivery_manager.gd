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
	# Load the resources
	organs = _load_resources("res://src/delivery/organs/resources/")
	recipients = _load_resources("res://src/characters/npcs/resources/")
	# Connect delivery zone signals
	for zone in delivery_zones:
		zone.activated.connect(complete_delivery)
	for zone in pickup_zones:
		zone.activated.connect(new_delivery)
	# Set the initial target for the first pickup
#	new_delivery()

# TODO - move to utils v

func _load_resources(dir_path: String) -> Array:
	var loaded_resources = []
	var resource_files = DirAccess.get_files_at(dir_path)
	for resource in resource_files:
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
	print("\n==== New Delivery: " + str(delivery) + " ====")
	print(str(_organ.name) + " for " + str(_recipient.name))
	update_delivery_queue(delivery)


func complete_delivery(last_zone: DeliveryZone) -> void:
	last_zone.is_active = false
	var delivery = delivery_queue.pop_front()
	# Update last used values
	last_used_organ = delivery.organ
	last_used_recipient = delivery.recipient
	last_used_delivery_zone = delivery.drop_off_location
	# Get a new pickup location
	next_pickup().is_active = true


func update_delivery_queue(new_delivery) -> void:
	delivery_queue.push_back(new_delivery)
	print("Queue:" + str(delivery_queue))
	print("================================================")
	# If the new delivery is first in the queue, start it
	if delivery_queue.find(new_delivery) == 0:
		new_delivery.start_delivery()


func generate_delivery(pickup_location: DeliveryZone, organ: Organ, recipient: Recipient) -> Delivery:
	# Generate a new delivery
	var delivery = Delivery.new()
	delivery.pickup_location = pickup_location
	delivery.drop_off_location = generate_drop_off(pickup_location)
	delivery.organ = organ
	delivery.reward = organ.base_value
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