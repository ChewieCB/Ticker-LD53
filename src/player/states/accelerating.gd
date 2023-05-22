extends MoveState


func enter() -> void:
	super.enter()
	is_crashed = false


func physics_process(delta: float) -> BaseState:
	super.physics_process(delta)
	
	if is_crashed:
		return crash_state
	
	if input_vector.y < 0:
		if actor.velocity.length() > 0:
			return braking_state
		else:
			return reverse_state
	elif input_vector.y == 0:
		return idle_state
	
	return null
