extends CharacterBody2D
class_name Player

@onready var animation_player = $AnimationPlayer
@onready var exhaust_sprite = $ExhaustSprite

var state_machine
var state_label


func _ready():
	state_machine = $StateMachine
	state_label = $DEBUG_StateLabel
	state_machine.init(self)
#	GlobalFlags.IS_PLAYER_CONTROLLABLE = true


func _physics_process(delta: float) -> void:	
	state_machine.physics_process(delta)


func _process(delta: float) -> void:
	state_machine.process(delta)

