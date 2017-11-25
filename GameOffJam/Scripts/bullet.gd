extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var draw_bullet = false

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	visible = false

func _physics_process(delta):
	var shoot = Input.is_action_just_pressed("ui_up")
	if shoot:
		$"..".cast_to = Vector2($"../..".face_direction * 500, 0)
		$"..".enabled = true
		var length = 0
		if $"..".get_collider():
			length = $"..".get_collision_point().x - global_position.x
		
		scale.x = length
		visible = true
		print(scale.x)
		