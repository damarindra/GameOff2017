extends "res://Scripts/character_controller.gd"

export var damage_given = 1
export var damage_push_power = 8

var move_direction = 1

func _ready():
	set_meta("type", "enemy")
	set_collision_mask_bit(1, true)
	set_collision_layer_bit(2, true)
	set_layer_and_mask_backup()
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _physics_process(delta):
	horizontal_input.axis = move_direction
	move()
	play_animation()
	
	if last_wall_normal != Vector2(0,0) or $RayGround.is_colliding() == false:
		$RayGround.position.x *= -1
		move_direction *= -1
	
	
	for col in contact_collisions:
		if col.get_collision_layer_bit(1):
			col.take_damage(damage_given, (col.get_center_position() - get_center_position()).normalized() * damage_push_power )

