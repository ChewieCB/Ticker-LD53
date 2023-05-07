extends Resource
class_name Dialog

enum DIALOG_TYPE {INFO, SUCCESS, FAIL}

var portrait: Texture2D
var type: DIALOG_TYPE
var reward: int
var organ_quality: float
var goal_organ_quality: float
var head_text: String
var subhead_text: String
var body_text: String
 

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
