extends "res://Scripts/enemy.gd"

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(PackedScene) var projectile
export var fire_rate = 1.0
export var projectile_damage = 1

onready var ray_length = $RayShoot.cast_to.x
var fire_counter = 0.0

var pooled_projectile = []

func _physics_process(delta):
	$RayShoot.cast_to.x = ray_length * face_direction
	
	if $RayShoot.is_colliding():
		move_direction = 0
		
		if fire_counter >= fire_rate:
			var p = projectile.instance()
			p.target_type = "player"
			p.owner = self
			p.damage_given = projectile_damage
			p.connect("_on_collide_with_body", self, "assign_to_pool")
			get_node("/root/Singleton").WORLD.add_child(p)
			
			var rewdata = get_node("/root/Singleton").WORLD.create_rewind_data(p, get_node("/root/Singleton").WORLD.fps)
			rewdata.assign_to("position", p.position)
			rewdata.assign_to("is_moving", false)
			rewdata.assign_to("time_left", 0)
			
			get_node("/root/Singleton").WORLD.node_projectile_data.push_back(rewdata)
			
			p.shoot($RayShoot.global_position, 8, $RayShoot.cast_to.normalized())
			
			$sfx.play()
			fire_counter = 0
		
		fire_counter += delta
	elif move_direction == 0:
		move_direction = face_direction

func assign_to_pool(_self, b):
	pooled_projectile.push_back(_self)
	