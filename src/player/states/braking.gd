extends MoveState


func enter() -> void:
	super.enter()


func physics_process(delta: float) -> BaseState:
	super.physics_process(delta)
	
	if is_crashed:
		return crash_state
	
	if input_vector.y > 0:
		return accelerate_state
	elif input_vector.y < 0:
		if steering_dot_prod < 0:
			return reverse_state
	elif input_vector.y == 0:
		return idle_state
	
	return null

