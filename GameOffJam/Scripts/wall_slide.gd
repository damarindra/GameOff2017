extends Node

export var WALL_SLIDE_SPEED = 1.0
export var WALL_JUMP = true
export var WALL_JUMP_POWER = Vector2(3, -4)

func wall_sliding(kc):
	get_parent().position.y -= kc.travel.y
	get_parent().velocity = Vector2(0, WALL_SLIDE_SPEED)
	
	return get_parent().move_and_collide(get_parent().velocity)

func wall_jump():
	get_parent().velocity = WALL_JUMP_POWER * Vector2(get_parent().last_wall_normal.x, 1)
