extends Resource
class_name Dialog

enum DIALOG_TYPE {INFO, SUCCESS, FAIL}

@export_group("Display")
@export var type: DIALOG_TYPE
@export var portrait: Texture2D
@export var head_text: String
@export var subhead_text: String
@export var body_text: String
@export_group("Behaviour")
@export var auto_fade: bool = true
@export var auto_fade_after: int = 2
@export var linked_dialog: Resource = null
@export_group("Value")
@export var reward: int
var organ_quality: float
var goal_organ_quality: float
 

func _init(
		p_type = DIALOG_TYPE.INFO, p_portrait = null,
		p_head_text = "", p_subhead_text = "", p_body_text = "",
		p_auto_fade = true, p_auto_fade_after = 2, p_linked_dialog = null,
		p_reward = 0, p_organ_quality = 1.0, p_goal_organ_quality = 1.0,
		
	):
	type = p_type
	portrait = p_portrait
	head_text = p_head_text
	subhead_text = p_subhead_text
	body_text = p_body_text
	auto_fade = p_auto_fade
	auto_fade_after = p_auto_fade_after
	linked_dialog = p_linked_dialog
	reward = p_reward
	organ_quality = p_organ_quality
	goal_organ_quality = p_goal_organ_quality
	
