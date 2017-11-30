extends Node2D

#must be inherit of character_controller
export var node_character = PoolStringArray()
#must be inherit of Node2D
#export var node_position = PoolStringArray()

export(NodePath) var PLAYER_PATH = null
export(NodePath) var CAMERA_PATH = null
export(Color) var color
var player setget , get_player
func get_player():
	if player == null:
		if PLAYER_PATH != null:
			player = get_node(PLAYER_PATH)
	return player

var camera setget , get_camera
func get_camera():
	if camera == null:
		if CAMERA_PATH != null:
			camera = get_node(CAMERA_PATH)
	return camera


#export var node_sprite = PoolStringArray()
var node_character_data = []
var node_projectile_data = []

#export(NodePath) var parallax_background

var fps = 300

var is_rewind = false
var can_rewind = true


var debug = false
var font = null

# all calculation using frame physics process
onready var max_rewind_time = fps
var current_rewind_time_available = 0
var rewind_time_regeneration_per_second = 30

func _ready():
	var label = Label.new()
	font = label.get_font("")
	label.free()
	
	$"..".get_node("StartScreen").time_bar.max_value = max_rewind_time
	
	for n in node_character:
		if n != "":
			node_character_data.push_back(RewindData.new(get_node(n), fps))
#	for n in node_position:
#		if n != "":
#			node_projectile_data.push_back(RewindData.new(get_node(n), fps))

func create_rewind_data(node, fps):
	return RewindData.new(node, fps)

func _physics_process(delta):
	if debug:
		update()
	
	$"..".get_node("StartScreen").time_bar.value = current_rewind_time_available
	
	if Input.is_action_pressed("rewind") and round(current_rewind_time_available) > 0 and can_rewind:
		is_rewind = true
		for n in node_character_data:
			if n.node.is_physics_processing():
				n.node.set_physics_process(false)
			if n.node.ANIM.is_playing():
				n.node.ANIM.stop()
			
			
			if n.value["position"].size() != 0:
				n.node.position = n.value["position"][n.value["position"].size() - 1]
				n.value["position"].pop_back()
				n.node.SPRITE.frame = n.value["frame"][n.value["frame"].size() - 1]
				n.value["frame"].pop_back()
				n.node.velocity = n.value["velocity"][n.value["velocity"].size() - 1]
				n.value["velocity"].pop_back()
				n.node.visible = n.value["visible"][n.value["visible"].size() - 1]
				n.value["visible"].pop_back()
				
				if n.node.velocity.x != 0:
					n.node.SPRITE.flip_h = sign(n.node.velocity.x) == -1
				
				var dead = n.node.current_health <= 0
				
				n.node.current_health = n.value["health"][n.value["health"].size() - 1]
				n.value["health"].pop_back()
				
				if dead and n.node.current_health > 0:
					for l in n.node._collision_layer_bit:
						n.node.set_collision_layer_bit(l, true)
					
					for m in n.node._collision_mask_bit:
						n.node.set_collision_mask_bit(m, true)
			
		
		
		for n in node_projectile_data:
			if n.value["position"].size() != 0:
				n.node.position = n.value["position"][n.value["position"].size() - 1]
				n.value["position"].pop_back()
				n.node.is_moving = n.value["is_moving"][n.value["is_moving"].size() - 1]
				n.value["is_moving"].pop_back()
				n.node.time_left = n.value["time_left"][n.value["time_left"].size() - 1]
				n.value["time_left"].pop_back()
				
				if not n.node.visible and n.node.is_moving:
					n.node.visible = true
					n.node.set_collision_layer_bit(0, true)
					n.node.set_collision_mask_bit(0, true)
				elif n.node.visible and not n.node.is_moving:
					n.node.visible = false
					n.node.set_collision_layer_bit(0, false)
					n.node.set_collision_mask_bit(0, false)
		
		current_rewind_time_available -= 1
		if round(current_rewind_time_available) == 0:
			enable_all_character()
			can_rewind = false
	
		
	else:
		is_rewind = false
		if Input.is_action_just_released("rewind"):
			#this condition is basically "don't do it again"
			if can_rewind:
				enable_all_character()
			can_rewind = true
	
	if is_rewind:
		return
	
	
	for n in node_character_data:
		n.assign_to("position", n.node.position)
		n.assign_to("frame", n.node.SPRITE.frame)
		n.assign_to("velocity", n.node.velocity)
		n.assign_to("health", n.node.current_health)
		n.assign_to("visible", n.node.visible)
#		n.assign_to("layer_bit", n.node.get_collision_layer_bit(0))
#		n.assign_to("layer_bit_disabled", n.node.get_collision_layer_bit(non_interactable_layer_mask))
		
	for n in node_projectile_data:
		n.assign_to("position", n.node.position)
		n.assign_to("is_moving", n.node.is_moving)
		n.assign_to("time_left", n.node.time_left)
	
	
	current_rewind_time_available += (rewind_time_regeneration_per_second * delta)
	if current_rewind_time_available > max_rewind_time:
		current_rewind_time_available = max_rewind_time

func enable_all_character():
	for n in node_character_data:
		if n.node.current_health <= 0:
			continue
		if not n.node.is_physics_processing():
			n.node.set_physics_process(true)
		if not n.node.ANIM.is_playing():
			n.node.ANIM.play("idle")


func _draw():
	if debug:
		draw_string(font, get_camera().global_position + Vector2(10,10), "STATIC : " + str(Performance.get_monitor(3)))
		draw_string(font, get_camera().global_position + Vector2(10,40), "DYNAMIC : " + str(Performance.get_monitor(4)))

class RewindData:
	var node
	#you can make value as array or dictionary
	#use assign(val) to make it array
	#use assign(key, val) to make it dict
	var value
	var size = 30
	
	func _init(node_, size_):
		node = node_
		size = size_
	
	func assign(val):
		if value == null:
			value = [val]
		else:
			value.push_back(val)
			if value.size() > size:
				value.pop_front()
	
	func assign_to(key, val):
		if value == null:
			value = {key : [val]}
		else:
			if value.has(key):
				value[key].push_back(val)
				if value[key].size() > size:
					value[key].pop_front()
			else:
				value[key] = [val]



