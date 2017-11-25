extends "res://Scripts/character_controller.gd"


func _ready():
	horizontal_input.pos_action = "ui_right"
	horizontal_input.neg_action = "ui_left"
	set_physics_process(true)

func _physics_process(delta):
#	if $"..".is_rewind:
#		ANIM.stop()
#		return
#	if ANIM.is_playing() == false:
#		ANIM.play("idle")
	
	horizontal_input.update()
	
	jump_just_pressed = Input.is_action_just_pressed("jump")
	jump_just_released = Input.is_action_just_released("jump")
	
	move()
	play_animation()
	
	
