extends "res://Scripts/character_controller.gd"


var move_direction = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _physics_process(delta):
	horizontal_input.axis = move_direction
	
	move()
	play_animation()
	
	if last_wall_normal != Vector2(0,0):
		move_direction *= -1
	