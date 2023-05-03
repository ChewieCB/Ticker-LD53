extends Resource
class_name Organ

@export_group("Display")
@export var name: String
@export var icon: Texture2D
@export_group("Value")
@export var base_value: int = 100
@export var min_value: int = 50
@export var max_value: int = 200
@export_group("Damage Characteristics")
@export var fragility: float = 1.0
@export var default_degredation_rate: float = 0.0
@export_group("Delivery Dialogue")
@export var successful_delivery_text: Array[String] = []
@export var successful_low_quality_delivery_text: Array[String] = []
@export var failed_damaged_delivery_text: Array[String] = []
@export var failed_timeout_delivery_text: Array[String] = []


func _init(
		p_name=null, p_icon=null, 
		p_fragility=1.0, p_default_degredation_rate=0.0,
		p_successful_delivery_text=[], p_successful_low_quality_delivery_text=[],
		p_failed_damaged_delivery_text=[], p_failed_timeout_delivery_text=[]
	):
		name = p_name
		icon = p_icon
		fragility = p_fragility
		default_degredation_rate = p_default_degredation_rate
		successful_delivery_text = p_successful_delivery_text
		successful_low_quality_delivery_text = p_successful_low_quality_delivery_text
		failed_damaged_delivery_text = p_failed_damaged_delivery_text
		failed_timeout_delivery_text = p_failed_timeout_delivery_text
