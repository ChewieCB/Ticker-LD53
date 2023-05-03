extends MoveState


func enter() -> void:
	super.enter()
	GlobalFlags.IS_PLAYER_CONTROLLABLE = false
	# Wait a bit and turn the engine back on
	await get_tree().create_timer(0.6).timeout
	# Hackity hack hack
	if not GlobalFlags.IS_GAME_OVER:
		GlobalFlags.IS_PLAYER_CONTROLLABLE = true


func physics_process(delta: float) -> BaseState:
	super.physics_process(delta)
	
	if input_vector.y > 0:
		return accelerate_state
	elif input_vector.y < 0:
		if actor.velocity.length() > 0:
			return braking_state
		else:
			return reverse_state
	elif input_vector.y == 0:
		return idle_state
	
	return null

