extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var timer = 0
var velocity = Vector2(-1,-1)

var kinematic_body_array = []

func _physics_process(delta):
	
	position += velocity
#	for kb in kinematic_body_array:
#		kb.move_and_collide(velocity)
	
	
	timer += delta
	
	if timer >= 3:
		timer = 0
		velocity *= -1

func register_kinematic_body(kinematic_body):
	if kinematic_body.get_class() == "KinematicBody2D":
		if !kinematic_body_array.has(kinematic_body):
			kinematic_body_array.push_back(kinematic_body)

func remove_kinematic_body(kinematic_body):
	if kinematic_body_array.has(kinematic_body):
		kinematic_body_array.erase(kinematic_body)