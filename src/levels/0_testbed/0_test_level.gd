extends Node2D

@export var shifts: Array


func _ready():
	for shift in shifts:
		if shift in PlayerManager.global_shift_array:
			return
	PlayerManager.global_shift_array += shifts

