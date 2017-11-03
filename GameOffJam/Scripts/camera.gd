extends Camera2D

export(NodePath) var PLAYER_PATH
export var FORWARD_DISTANCE = 30
export var MAX_Y_OFFSET = 30
export var SMOOTHING = Vector2(.03, .1)
onready var player = get_node(PLAYER_PATH)

onready var pixel_perfect = ProjectSettings.get_setting("display/window/stretch/mode") == "viewport"
onready var origin_offset_value = offset
onready var real_position = global_position

onready var y_offset = offset.y

func _ready():
	offset.y = 0
	limit_left = $Limit.global_position.x - ($Limit.global_scale.x * 32)
	limit_right = $Limit.global_position.x + ($Limit.global_scale.x * 32)
	limit_top = $Limit.global_position.y - ($Limit.global_scale.y * 32)
	limit_bottom = $Limit.global_position.y + ($Limit.global_scale.y * 32)
	set_physics_process(true)

func _physics_process(delta):
	real_position.x = lerp(real_position.x, player.get_center_position().x + player.face_direction * FORWARD_DISTANCE, SMOOTHING.x)
	real_position.y = lerp(real_position.y, player.get_center_position().y + y_offset, SMOOTHING.y)
	
	if abs(real_position.y - player.get_center_position().y) > MAX_Y_OFFSET:
		real_position.y = player.get_center_position().y + (MAX_Y_OFFSET * (sign(real_position.y - player.get_center_position().y)))
	
	if pixel_perfect:
		global_position = Vector2(round(real_position.x), round(real_position.y))
	else:
		global_position = real_position
