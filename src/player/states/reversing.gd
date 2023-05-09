extends MoveState


func enter() -> void:
	super.enter()


func physics_process(delta: float) -> BaseState:
	super.physics_process(delta)
	
	if input_vector.y > 0:
		return accelerate_state
	elif input_vector.y == 0:
		return idle_state
	
	return null

