extends Node

var WORLD
onready var pixel_perfect = ProjectSettings.get_setting("display/window/stretch/mode") == "viewport"

var loading_time_max = 10 #ms
var loader = null
var current_scene_path

func goto_scene(path, free_current = true):
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
		print("path doesn't found")
		current_scene_path = ""
		return
	else:
		current_scene_path = path
	
	get_parent().get_node("StartScreen").show_loading()
	
	set_process(true)
	
	var root = get_node("/root")
	if free_current:
		root.get_child(root.get_child_count() - 1).queue_free()

func restart_scene():
	goto_scene(current_scene_path)

func _process(delta):
	if loader == null:
		set_process(false)
		return
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + loading_time_max: # use "time_max" to control how much time we block this thread
		# poll your loader
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # load finished
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			get_parent().get_node("StartScreen").hide_loading()
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			print("error during loading")
			loader = null
			break

func update_progress():
	print(float(loader.get_stage()) / loader.get_stage_count())

func set_new_scene(scene_resource):
	WORLD = scene_resource.instance()
	get_node("/root").add_child(WORLD)