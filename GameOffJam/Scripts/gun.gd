extends Position2D

export(PackedScene) var PROJECTILE
export var FIRE_RATE = 0.2
export var SPEED = 15
export var Y_FUZZY_MAX = 0.5
export var DAMAGE = 2

var can_shoot = true
var is_shooting = false
var time_left = 0

var pooled_projectile = []

onready var gun_sfx = preload("res://gun2.wav")

#func setup_scale():
#	SPEED *= get_node("/root/Singleton").WORLD.SCALE
#
#func _ready():
#	setup_scale()

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_up") and can_shoot:
		var p = null
		for _pp in pooled_projectile:
			if _pp.ready_to_reuse:
				p = _pp
				pooled_projectile.erase(_pp)
				break
		if p == null:
			p = PROJECTILE.instance(PackedScene.GEN_EDIT_STATE_DISABLED)
			p.connect("_on_collide_with_body", self, "assign_to_pool")
			get_node("/root/Singleton").WORLD.add_child(p)
			p.owner = get_parent()
			p.damage_given = DAMAGE
			p.target_type = "enemy"
			
			var rewdata = get_node("/root/Singleton").WORLD.create_rewind_data(p, get_node("/root/Singleton").WORLD.fps)
			rewdata.assign_to("position", p.position)
			rewdata.assign_to("is_moving", false)
			rewdata.assign_to("time_left", 0)
			
			get_node("/root/Singleton").WORLD.node_projectile_data.push_back(rewdata)
			
		
		var pos = global_position
		if $"..".face_direction == -1:
			pos.x -= position.x * 2
		
		var dir = Vector2(1, (randf() * Y_FUZZY_MAX) - (Y_FUZZY_MAX / 2))
		p.shoot(pos, SPEED, $"..".face_direction * dir)
		can_shoot = false
		is_shooting = true
		get_tree().create_timer(FIRE_RATE).connect("timeout", self, "enable_ability_to_shoot")
		time_left = FIRE_RATE * 2
		
		$"../Gun".stream = gun_sfx
		$"../Gun".play()
	
	if time_left <= 0 and is_shooting:
		is_shooting = false
	else:
		time_left -= delta

func enable_ability_to_shoot():
	can_shoot = true

func assign_to_pool(_self, b):
	pooled_projectile.push_back(_self)
	