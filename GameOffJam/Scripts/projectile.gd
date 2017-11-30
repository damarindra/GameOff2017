extends Area2D

signal _on_collide_with_another_projectile(_self, projectile)
signal _on_collide_with_body(_self, body)

var is_moving = false
var speed = 0.0
var direction = Vector2()
var ready_to_reuse = false
var owner = null
var damage_given = 1
var target_type = ""

export var life_time = 1
var time_left

func _ready():
	visible = false

func _physics_process(delta):
	if get_node("/root/Singleton").WORLD.is_rewind:
		return
	
	
	if is_moving:
		print(time_left)
		time_left -= delta
		if time_left > 0:
			position += direction * speed
		else:
			emit_signal("_on_collide_with_body", self, null)
			visible = false
			is_moving = false
			ready_to_reuse = true
			set_collision_layer_bit(0, false)
			set_collision_mask_bit(0, false)
	
		for bd in get_overlapping_bodies():
			if bd != owner:
				print(bd)
				emit_signal("_on_collide_with_body", self, bd)
				visible = false
				is_moving = false
				ready_to_reuse = true
				set_collision_layer_bit(0, false)
				set_collision_mask_bit(0, false)
				if bd.get_meta("type") == target_type:
					bd.take_damage(damage_given, Vector2(0,0))
				break


func shoot(start_pos, speed, direction):
	
	set_collision_layer_bit(0, true)
	set_collision_mask_bit(0, true)
	
	time_left = life_time
	global_position = start_pos
	self.speed = speed
	self.direction = direction
	
	if sign(direction.x) == -1:
		scale.x = -1
	
	ready_to_reuse = false
	is_moving = true
	visible = true

func stop():
	is_moving = false

#func _on_Projectile_body_entered( body ):
#	if body == owner or get_node("/root/Singleton").WORLD.is_rewind:
#		return
##
#	if body.is_class("Projectile"):
#		emit_signal("_on_collide_with_another_projectile", self, body)
#	else:
#		emit_signal("_on_collide_with_body", self, body)
#		visible = false
#		is_moving = false
#		ready_to_reuse = true
#		set_collision_layer_bit(0, false)
#		set_collision_mask_bit(0, false)
#
#		if body.get_meta("type") != null:
#			if body.get_meta("type") == "character_controller":
#				body.take_damage(damage_given, Vector2(0,0))



