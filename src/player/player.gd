extends CharacterBody2D
class_name Player

@onready var animation_player = $AnimationPlayer
@onready var exhaust_sprite = $ExhaustSprite

@onready var starting_position = self.position

var state_machine
var state_label


func _ready():
	state_machine = $StateMachine
	state_label = $DEBUG_StateLabel
	state_machine.init(self)
	ShiftManager.shift_finished.connect(reset_player)
#	GlobalFlags.IS_PLAYER_CONTROLLABLE = true


func _input(event: InputEvent):
	# Debug/Utility controls
	if Input.is_action_pressed("quit"):
		get_tree().quit()
	elif Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:	
	state_machine.physics_process(delta)


func _process(delta: float) -> void:
	state_machine.process(delta)


func reset_player() -> void:
	self.velocity = Vector2.ZERO
	self.position = starting_position
	self.rotation = 0
	move_and_slide()

