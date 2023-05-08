extends Resource
class_name Dialog

enum DIALOG_TYPE {INFO, SUCCESS, FAIL}

@export_group("Display")
@export var type: DIALOG_TYPE
@export var portrait: Texture2D
@export var head_text: String
@export var subhead_text: String
@export var body_text: String
@export var reward: int
var organ_quality: float
var goal_organ_quality: float
 

func _init(
		p_portrait = null, p_type = DIALOG_TYPE.INFO, 
		p_reward = 0, p_organ_quality = 1.0, p_goal_organ_quality = 1.0,
		p_head_text = "", p_subhead_text = "", p_body_text = ""
	):
	portrait = p_portrait
	type = p_type
	reward = p_reward
	organ_quality = p_organ_quality
	goal_organ_quality = p_goal_organ_quality
	head_text = p_head_text
	subhead_text = p_subhead_text
	body_text = p_body_text
