class_name MoveState
extends BaseState
# Parent state for all movement-related states for the Player
# Holds all of the base movement logic
# Child states can override this states's functions or change its properties
# This keeps the logic grouped in one location

signal crashed

@export_group("Rendering")
@export var is_exhaust_visible: bool = false

# These should be fallback defaults
# TODO: Make these null and raise an exception to indicate bad State extension
#       to better separate movement vars.
@export_group("Handling")
@export_subgroup("Engine")
@export var engine_power = 750
@export var acceleration = Vector2.ZERO
@export var max_speed_reverse = 55
@export_subgroup("Braking")
@export var braking_power = -320
@export var handbrake_power = -200
@export_subgroup("Traction")
@export var friction = -0.45
@export var drag = -0.004
@export var slip_speed = 500 # Speed where traction is reduced
@export var traction_drift = 0.01 # Drifting traction
@export var traction_fast = 0.1  # High-speed traction
@export var traction_slow = 0.7  # Low-speed traction
@export_subgroup("Steering")
@export var wheel_base = 34
@export var steering_angle_high = 65
@export var steering_angle_low = 30
@export_subgroup("Collision Behaviour")
@export var bounce_speed = 150 # Speed at which collisions cause the player to bounce off
@export var crash_friction_factor: int = 10 # How much friction increases during the crashed state
@export var crash_hang_time: float = 0.4 # How long the player loses control upon a crash

var steering_angle = steering_angle_low
var steer_direction

var input_direction = Vector2.ZERO
var steer_angle
var steering_dot_prod

@export_group("States")
@export var idle_state: MoveState
@export var accelerate_state: MoveState
@export var braking_state: MoveState
@export var reverse_state: MoveState
@export var crash_state: MoveState

var input_vector: Vector2
var is_crashed: bool = false


func _ready():
	var parent = get_parent()
	if parent is MoveState:
		idle_state = parent.idle_state
		accelerate_state = parent.accelerate_state
		braking_state = parent.braking_state
		reverse_state = parent.reverse_state
		crash_state = parent.crash_state
	
	crashed.connect(crash)


func enter():
	actor.exhaust_sprite.visible = is_exhaust_visible


func physics_process(delta: float) -> BaseState:
	acceleration = Vector2.ZERO
	
	var input_vector = get_input()
	
	apply_friction()
	calculate_steering(delta)
	
	actor.velocity += acceleration * delta
	
	handle_collisions(actor.velocity, delta)
	
	return null


func get_input() -> Vector2:
	input_vector = Input.get_vector(
		"turn_right", "turn_left", 
		"decelerate", "accelerate"
	)
		
	var turn = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	steer_angle = turn * deg_to_rad(steering_angle)
	
	if input_vector.y > 0:
		acceleration = actor.transform.x * engine_power
	elif input_vector.y < 0:
		acceleration = actor.transform.x * braking_power
	
#	if Input.is_action_pressed("handbrake"):
#		if velocity.length() > 0:
#			_state_machine.transition_to("Movement/Drifting")
#			steering_angle = lerp(steering_angle, steering_angle_high, 0.2)
#			acceleration = _actor.transform.x * handbrake_power
#			friction = lerp(friction, -0.1, 0.5)
#		else:
#			steering_angle = lerp(steering_angle, steering_angle_low, 0.5)
#			friction = lerp(friction, -1.4, 0.5)
#	else:
	steering_angle = steering_angle_low
	friction = lerp(friction, -1.4, 0.5)
	
	var anim = ""
	match int(turn):
		-1:
			anim = "left"
		0:
			anim = "idle"
		1:
			anim = "right"
	if anim:
		actor.animation_player.play(anim)
	
	return input_vector


func apply_friction():
	if actor.velocity.length() < 5:
		actor.velocity = Vector2.ZERO
	
	var friction_force = actor.velocity * friction
	var drag_force = actor.velocity * actor.velocity.length() * drag
	
	if actor.velocity.length() < 20:
		friction_force *= 3
#	if Input.is_action_pressed("handbrake"):
#		friction_force *= 0.6
	acceleration += drag_force + friction_force


func calculate_steering(delta):
	var rear_wheel = actor.position - actor.transform.x * wheel_base / 2.0
	var front_wheel = actor.position + actor.transform.x * wheel_base / 2.0
	rear_wheel += actor.velocity * delta
	front_wheel += actor.velocity.rotated(steer_angle) * delta
	
	var new_heading = (front_wheel - rear_wheel).normalized()
	
	var traction = traction_slow
	if actor.velocity.length() > slip_speed:
		if Input.is_action_pressed("handbrake"):
			traction = traction_drift
		else:
			traction = traction_fast
	steering_dot_prod = new_heading.dot(actor.velocity.normalized())
	if steering_dot_prod > 0:
		actor.velocity = actor.velocity.lerp(new_heading * actor.velocity.length(), traction)
	if steering_dot_prod < 0:
		actor.velocity = -new_heading * min(actor.velocity.length(), max_speed_reverse)
	
	actor.rotation = new_heading.angle()


func handle_collisions(velocity, delta):
	# If we're going fast, bounce off the wall 
	if velocity.length() > bounce_speed:
		var collision = actor.move_and_collide(velocity * delta)
		if collision:
			# Turn off the engine for a second
			var test0 = collision.get_normal()
			var test1 = velocity.bounce(collision.get_normal())
			actor.velocity = velocity.bounce(collision.get_normal()) * 1.4
			emit_signal("crashed")
	else:
		actor.velocity = velocity
	actor.move_and_slide()


func crash() -> void:
	is_crashed = true

