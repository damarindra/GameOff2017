extends Node

export(NodePath) var HEALTH_BAR_PATH = null
export(NodePath) var TIME_BAR_PATH = null
export(NodePath) var LOADING_PATH = null


var health_bar setget , get_health_bar
func get_health_bar():
	if health_bar == null:
		if HEALTH_BAR_PATH != null:
			health_bar = get_node(HEALTH_BAR_PATH)
	return health_bar

var time_bar setget , get_time_bar
func get_time_bar():
	if time_bar == null:
		if TIME_BAR_PATH != null:
			time_bar = get_node(TIME_BAR_PATH)
	return time_bar

var loading setget , get_loading
func get_loading():
	if loading == null:
		if LOADING_PATH != null:
			loading = get_node(LOADING_PATH)
	return loading


func _ready():
#	OS.set_window_size(OS.get_window_size() * 3)
	get_node("/root/Singleton").goto_scene("res://Scenes/World.tscn", false)
	get_loading().visible = false
	get_loading().rect_size = get_node("/root").size

func show_loading():
	get_loading().visible = true

func hide_loading():
	get_loading().visible = false