extends "res://Scripts/character_controller.gd"

var time_to_recover_from_dead = 3
var recover_from_dead_counter = 0
onready var health_bar = get_node("/root").get_node("StartScreen").health_bar
export(AudioStream) var jump_sfx = null
export(AudioStream) var ground_sfx = null

onready var _jump_sfx = preload("res://jump.wav")
onready var _ground_sfx = preload("res://grounded.wav")
#var walk_step_time_sfx = .6
#var walk_step_sfx_counter = 0.0
export var footstep_toggle = false
var min_footstep_rest_time = 0.3
var footstep_rest_counter = 0

func _ready():
	horizontal_input.pos_action = "ui_right"
	horizontal_input.neg_action = "ui_left"
	set_collision_layer_bit(1, true)
	set_collision_mask_bit(2, true)
	health_bar.value = current_health
	
	set_layer_and_mask_backup()
	
	set_physics_process(true)
	set_meta("type", "player")

func _physics_process(delta):
#	if $"..".is_rewind:
#		ANIM.stop()
#		return
#	if ANIM.is_playing() == false:
#		ANIM.play("idle")
	
	horizontal_input.update()
	
	jump_just_pressed = Input.is_action_just_pressed("jump")
	jump_just_released = Input.is_action_just_released("jump")
	
	var ground_before = is_grounded
	
	move()
	play_animation()
	
	if jump_just_pressed and is_jumping:
		$SfxChar.set_stream(_jump_sfx)
		$SfxChar.play()
	
	if footstep_toggle and not $Sfx_Ground.playing and is_grounded and footstep_rest_counter >= min_footstep_rest_time:
		$Sfx_Ground.play()
		footstep_toggle = false
		footstep_rest_counter = 0
	
	footstep_rest_counter += delta
#	if walk_step_sfx_counter >= walk_step_time_sfx:
#		$SfxChar.stream = _ground_sfx
#		$SfxChar.play()
#		walk_step_sfx_counter = 0
#	if velocity.x != 0 and is_grounded:
#		walk_step_sfx_counter += delta
#	elif not ground_before and is_grounded:
#		$SfxChar.stream = _ground_sfx
#		$SfxChar.play()
	
	for col in contact_collisions:
		if col.get_collision_layer_bit(2):
			take_damage(col.damage_given, (get_center_position() - col.get_center_position()).normalized() * col.damage_push_power)
#				get_node("/root").get_node("StartScreen").health_bar.value -= col.damage_given
	if health_bar.value != current_health:
		health_bar.value = current_health

func _process(delta):
	if $"..".is_rewind:
		return
	if current_health <= 0:
		recover_from_dead_counter += delta
		if recover_from_dead_counter >= time_to_recover_from_dead:
			get_node("/root/Singleton").restart_scene()
	elif recover_from_dead_counter > 0:
		recover_from_dead_counter = 0
