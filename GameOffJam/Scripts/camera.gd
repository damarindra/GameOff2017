extends Camera2D

export var FORWARD_DISTANCE = 30
export var MAX_Y_OFFSET = 30
export var SMOOTHING = Vector2(.03, .1)

onready var origin_offset_value = offset
onready var real_position = global_position
onready var min_pixel_move = 0.2

onready var y_offset = offset.y


func _ready():
	drag_margin_v_enabled = false
	drag_margin_h_enabled = false
	smoothing_enabled = false
	smoothing_speed = 0
	offset.y = 0
	limit_left = $Limit.global_position.x - ($Limit.global_scale.x * 32)
	limit_right = $Limit.global_position.x + ($Limit.global_scale.x * 32)
	limit_top = $Limit.global_position.y - ($Limit.global_scale.y * 32)
	limit_bottom = $Limit.global_position.y + ($Limit.global_scale.y * 32)
	set_physics_process(true)

func _physics_process(delta):
#	if $"..".is_rewind:
#		real_position = global_position
#		return
	if $"..".is_rewind:
		real_position.x = lerp(real_position.x, $"..".player.get_center_position().x + sign($"..".player.velocity.x) * -1 * FORWARD_DISTANCE, SMOOTHING.x)
	else:
		real_position.x = lerp(real_position.x, $"..".player.get_center_position().x + $"..".player.face_direction * FORWARD_DISTANCE, SMOOTHING.x)
	real_position.y = lerp(real_position.y, $"..".player.get_center_position().y + y_offset, SMOOTHING.y)
	
	if abs(real_position.y - $"..".player.get_center_position().y) > MAX_Y_OFFSET:
		real_position.y = $"..".player.get_center_position().y + (MAX_Y_OFFSET * (sign(real_position.y - $"..".player.get_center_position().y)))
	
	if get_node("/root/Singleton").pixel_perfect:
		global_position = Vector2(round(real_position.x), round(real_position.y))
	else:
		global_position = Vector2(stepify(real_position.x, min_pixel_move), stepify(real_position.y, min_pixel_move))
