extends Sprite

signal _on_collide_with_another_projectile(projectile)
signal _on_collide_with_body(body)

var is_moving = false
var speed = 0.0
var direction = Vector2()

func _physics_process(delta):
	if is_moving:
		position += direction * speed

func shoot(start_pos, speed, direction):
	global_position = start_pos
	self.speed = speed
	self.direction = direction
	is_moving = true

func stop():
	is_moving = false

func pool_this_to(node):
	pass

func _on_Area2D_body_entered( body ):
	if body.is_class("Projectile"):
		emit_signal("_on_collide_with_another_projectile", body)
	else:
		emit_signal("_on_collide_with_body", body)
