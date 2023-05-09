extends Node

signal transitioned

@export_group("Player SFX")
@export var accel_sfx: AudioStreamMP3
@export var breakthrough_sfx: AudioStreamMP3
@export var engine_sfx: AudioStreamMP3
@export var top_speed_sfx: AudioStreamMP3
@export var decel_sfx: AudioStreamMP3
@export var drift_sfx_1: AudioStreamMP3
@export var drift_sfx_2: AudioStreamMP3
@export var drift_sfx_3: AudioStreamMP3
@export var drift_piston_sfx: AudioStreamMP3
@export var crash_sfx_1: AudioStreamMP3
@export var crash_sfx_2: AudioStreamMP3
@export var crash_sfx_3: AudioStreamMP3
@export var crash_sfx_4: AudioStreamMP3
@export var crash_bad_sfx: AudioStreamMP3
@export var engine_stop_sfx: AudioStreamMP3
@export var engine_stutter_sfx: AudioStreamMP3
@export var death_sfx_1: AudioStreamMP3
@export var death_sfx_2: AudioStreamMP3

enum States { 
	# Null state to stop looping samples
	IDLE,
	# Player SFX States
	ACCELERATING, TOP_SPEED, DECELERATING, DRIFTING, CRASH,
	DEATH
	}

enum PlayerIDs {
	ENGINE_LOOP,
	ACCEL,
	DECEL,
	DRIFT,
	CRASH,
	BREAKTHROUGH,
	DEATH,
	AUX
}

@onready var tween = $Tween
@onready var sfx_players = get_children()

var engine_player
var accel_player
var decel_player
var drift_player
var crash_player
var breakthrough_player
var death_player
var aux_player


func _ready():
	sfx_players.erase(tween)
	
	engine_player = sfx_players[PlayerIDs.ENGINE_LOOP]
	engine_player.stream = engine_sfx
	# Set initial engine params
	engine_player.volume_db = -20
	engine_player.pitch_scale = 0.5
	if engine_player.stream:
		engine_player.play()
	#
	accel_player = sfx_players[PlayerIDs.ACCEL]
	accel_player.stream = accel_sfx
	accel_player.volume_db = -80
	
	decel_player = sfx_players[PlayerIDs.DECEL]
	decel_player.stream = decel_sfx
	decel_player.volume_db = -80
	
	drift_player = sfx_players[PlayerIDs.DRIFT]
	drift_player.stream = random_drift_sfx()
	drift_player.volume_db = -20
	
	crash_player = sfx_players[PlayerIDs.CRASH]
	crash_player.stream = random_crash_sfx()
	
	breakthrough_player = sfx_players[PlayerIDs.BREAKTHROUGH]
	breakthrough_player.stream = breakthrough_sfx
	
	death_player = sfx_players[PlayerIDs.DEATH]
	death_player.stream = random_death_sfx()
	decel_player.volume_db = -30
	
	aux_player = sfx_players[PlayerIDs.AUX]
	aux_player.volume_db = -20


#func _physics_process(_delta):
#	print("\n")
#	print(engine_player.volume_db)
#	print(engine_player.pitch_scale)


func play_audio(state):
	# Match the state to the sample
	match state:
		States.IDLE:
			tween.interpolate_property(
				engine_player,
				"volume_db",
				engine_player.volume_db,
				-20,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				engine_player,
				"pitch_scale",
				engine_player.pitch_scale,
				0.5,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				accel_player,
				"volume_db",
				accel_player.volume_db,
				-80,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.start()
			await tween.tween_all_completed
			engine_player.volume_db = -20
			engine_player.pitch_scale = 0.5
		States.ACCELERATING:
			if accel_player.stream:
				accel_player.play()
			tween.interpolate_property(
				engine_player,
				"volume_db",
				engine_player.volume_db,
				-16,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				engine_player,
				"pitch_scale",
				engine_player.pitch_scale,
				1.5,
				3.0,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				accel_player,
				"volume_db",
				accel_player.volume_db,
				-8,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.start()
			await tween.tween_all_completed
			engine_player.volume_db = -16
			engine_player.pitch_scale = 1.5
		States.DECELERATING:
			if accel_player.stream:
				accel_player.play()
			tween.interpolate_property(
				engine_player,
				"volume_db",
				engine_player.volume_db,
				-20,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				engine_player,
				"pitch_scale",
				engine_player.pitch_scale,
				0.5,
				3.0,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				decel_player,
				"volume_db",
				decel_player.volume_db,
				-8,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.start()
			await tween.tween_all_completed
			# TODO - transition to high speed engine noise here
			engine_player.volume_db = -16
			engine_player.pitch_scale = 1.5
		States.CRASH:
			# Impact noise
			crash_player.stream = random_crash_sfx()
			if crash_player.stream:
				crash_player.play()
			# Engine failure noise
			aux_player.stream = engine_stop_sfx
			if aux_player.stream:
				aux_player.play()
			#
			tween.interpolate_property(
				engine_player,
				"volume_db",
				engine_player.volume_db,
				-70,
				0.3,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				engine_player,
				"pitch_scale",
				engine_player.pitch_scale,
				0.5,
				0.3,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				accel_player,
				"volume_db",
				accel_player.volume_db,
				-80,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.start()
			await tween.tween_all_completed
			# Reset engine noise
			tween.interpolate_property(
				engine_player,
				"volume_db",
				engine_player.volume_db,
				-20,
				0.15,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				engine_player,
				"pitch_scale",
				engine_player.pitch_scale,
				0.5,
				0.15,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.start()
			await tween.tween_all_completed
		States.DRIFTING:
			if drift_player.stream:
				drift_player.play()
			aux_player.stream = drift_piston_sfx
			if aux_player.stream:
				aux_player.play()
			tween.interpolate_property(
				engine_player,
				"volume_db",
				engine_player.volume_db,
				-20,
				0.7,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				engine_player,
				"pitch_scale",
				engine_player.pitch_scale,
				0.5,
				0.7,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				accel_player,
				"volume_db",
				accel_player.volume_db,
				-20,
				0.7,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.start()
		States.DEATH:
			if death_player.stream:
				death_player.play()
			tween.interpolate_property(
				engine_player,
				"volume_db",
				engine_player.volume_db,
				-70,
				0.3,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				engine_player,
				"pitch_scale",
				engine_player.pitch_scale,
				0.5,
				0.3,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.interpolate_property(
				accel_player,
				"volume_db",
				accel_player.volume_db,
				-80,
				0.6,
				Tween.TRANS_SINE,
				Tween.EASE_OUT
			)
			tween.start()
			await tween.tween_all_completed


func random_drift_sfx():
	var _samples = [drift_sfx_1, drift_sfx_2, drift_sfx_3]
	_samples.erase(drift_player.stream)
	var rand_idx = floor(randi_range(0, _samples.size()))
	
	return _samples[rand_idx]


func random_crash_sfx():
	var _samples = [crash_sfx_1, crash_sfx_2, crash_sfx_3, crash_sfx_4]
	_samples.erase(crash_player.stream)
	var rand_idx = floor(randi_range(0, _samples.size()))
	
	return _samples[rand_idx]


func random_death_sfx():
	var _samples = [death_sfx_1, death_sfx_2]
	_samples.erase(death_player.stream)
	var rand_idx = floor(randi_range(0, _samples.size()))
	
	return _samples[rand_idx]


func stop_audio():
	for player in sfx_players:
		if player == engine_player:
			continue
		player.stop()
		player.stream = null


func transition_to(state):
#	stop_audio()
	play_audio(state)
	emit_signal("transitioned", state)
