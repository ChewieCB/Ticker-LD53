extends MoveState


func enter() -> void:
	super.enter()
	is_crashed = true
	GlobalFlags.IS_PLAYER_CONTROLLABLE = false
	# Increase the friction for a bouncy rebound that stops quickly
	friction *= crash_friction_factor
	# Wait a bit and turn the engine back on
	await get_tree().create_timer(crash_hang_time).timeout
	is_crashed = false


func physics_process(delta: float) -> BaseState:
	if not is_crashed:
		if input_vector.y > 0:
			return accelerate_state
		elif input_vector.y < 0:
			if actor.velocity.length() > 0:
				return braking_state
			else:
				return reverse_state
		elif input_vector.y == 0:
			return idle_state
	
	acceleration = Vector2.ZERO
	
	apply_friction()
	
	actor.velocity += acceleration * delta
	
	handle_collisions(actor.velocity, delta)
	
	return null


func handle_collisions(velocity, delta):
	actor.velocity = velocity
	actor.move_and_slide()


func exit() -> void:
	# Reset the friction
	friction /= crash_friction_factor
	# Regain player control
	if not GlobalFlags.IS_GAME_OVER:
		GlobalFlags.IS_PLAYER_CONTROLLABLE = true

