extends Sprite

signal _on_collide_with_another_projectile(_self, projectile)
signal _on_collide_with_body(_self, body)

var is_moving = false
var speed = 0.0
var direction = Vector2()
var ready_to_reuse = false
var owner = null

export var life_time = 1
var time_left

func _ready():
	visible = false

func _physics_process(delta):
	
	if is_moving:
		time_left -= delta
		if time_left > 0:
			position += direction * speed
		else:
			emit_signal("_on_collide_with_body", self, null)
			visible = false
			is_moving = false
			ready_to_reuse = true
	
	for bd in get_node("Area2D").get_overlapping_bodies():
		if bd != owner:
			emit_signal("_on_collide_with_body", self, null)
			visible = false
			is_moving = false
			ready_to_reuse = true
			break


func shoot(start_pos, speed, direction):
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

func _on_Area2D_body_entered( body ):
	if body == owner:
		return
	
	if body.is_class("Projectile"):
		emit_signal("_on_collide_with_another_projectile", self, body)
	else:
		emit_signal("_on_collide_with_body", self, body)
		visible = false
		is_moving = false
		ready_to_reuse = true

