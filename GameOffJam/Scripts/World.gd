extends Node2D

#must be inherit of character_controller
export var node_character = PoolStringArray()
#must be inherit of Node2D
export var node_position = PoolStringArray()
export var SCALE = 3

export(NodePath) var PLAYER_PATH = null
export(NodePath) var CAMERA_PATH = null

var player
var camera
#export var node_sprite = PoolStringArray()
var node_character_data = []
var node_position_data = []

#export(NodePath) var parallax_background

var fps = 60

var is_rewind = false
var can_rewind = true 

#var value_watcher

var debug = true
var font = null

func setup_scale():
#	if parallax_background != null:
#		var parallax = get_node(parallax_background)
#		for p in parallax.get_childs():
#			p.scale *= SCALE
	
	OS.set_window_size(OS.get_window_size() * SCALE)
#	scale *= SCALE

func _ready():
	setup_scale()
	
	var label = Label.new()
	font = label.get_font("")
	label.free()
	
	if PLAYER_PATH != null:
		player = get_node(PLAYER_PATH)
	if CAMERA_PATH != null:
		camera = get_node(CAMERA_PATH)
	
	for n in node_character:
		if n != "":
			node_character_data.push_back(RewindData.new(get_node(n), fps * 3))
	for n in node_position:
		if n != "":
			node_position_data.push_back(RewindData.new(get_node(n), fps * 3))

func _physics_process(delta):
	if debug:
		update()
	
	if Input.is_action_pressed("rewind"):
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
		for n in node_position_data:
			if n.value.size() != 0:
				n.node.position = n.value[n.value.size()-1]
				n.value.pop_back()
	elif Input.is_action_just_released("rewind"):
		for n in node_character_data:
			if not n.node.is_physics_processing():
				n.node.set_physics_process(true)
			if not n.node.ANIM.is_playing():
				n.node.ANIM.play("idle")
				
		is_rewind = false
	
	if is_rewind:
		return
	
	
#	for n in node_character_data:
#		n.assign_to("position", n.node.position)
#		n.assign_to("frame", n.node.SPRITE.frame)
#		n.assign_to("velocity", n.node.velocity)
#	for n in node_position_data:
#		n.assign(n.node.position)


func _draw():
	if debug:
		draw_string(font, camera.global_position + Vector2(10,10), "STATIC : " + str(Performance.get_monitor(3)))
		draw_string(font, camera.global_position + Vector2(10,40), "DYNAMIC : " + str(Performance.get_monitor(4)))

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



