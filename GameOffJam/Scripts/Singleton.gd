extends Node

onready var WORLD = get_node("/root/World")
onready var pixel_perfect = ProjectSettings.get_setting("display/window/stretch/mode") == "viewport"