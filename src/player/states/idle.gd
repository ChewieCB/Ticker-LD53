extends MoveState


func enter() -> void:
	super.enter()


func physics_process(delta: float) -> BaseState:
	super.physics_process(delta)
	
	if input_vector.y > 0:
		return accelerate_state
	elif input_vector.y < 0:
		if steering_dot_prod > 0:
			return braking_state
		else:
			return reverse_state
	
	return null
