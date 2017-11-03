extends KinematicBody2D

export(NodePath) var SPRITE_PATH
onready var SPRITE = get_node(SPRITE_PATH)
export(NodePath) var ANIM_PATH
onready var ANIM = get_node(ANIM_PATH)
export(NodePath) var WALL_SLIDE_PATH
var WALL_SLIDE
export var FLOOR_ANGLE = 45.0
export var GRAVITY = 10.0
export var MOVE_SPEED = 3.0
export var MOVE_TIME = .15
export var STOP_TIME = .15
export var MAX_JUMP_POWER = 5.0
export var MIN_JUMP_POWER = 3.0
export var MAX_AIR_JUMP = 1
export var MAX_AIR_JUMP_POWER = 3.5
export var MIN_AIR_JUMP_POWER = 1.0
export var FLIP_COLLIDER_OFFSET = Vector2(0,0)

onready var move_step = MOVE_SPEED / MOVE_TIME
onready var stop_step = MOVE_SPEED / STOP_TIME
onready var collider = shape_owner_get_owner(0)
onready var collider_origin_position = shape_owner_get_owner(0).position

var face_direction = 0
var is_grounded = false
var is_walled = false
var is_ceiled = false
#only used for handling slope movement
var is_try_jumping = false
var is_jumping = false setget , get_is_jumping
var is_falling = false setget , get_is_falling
var last_ground_normal = Vector2(0,0)
var last_wall_normal = Vector2(0,0)
var last_ceil_normal = Vector2(0,0)
var last_moving_platform = null

#input
var horizontal_input = InputAxis.new("", "")
var vertical_input = InputAxis.new("", "")
var jump_just_pressed = false
var jump_just_released = false

var velocity = Vector2()
var air_jump_count = 0
var bounce_count = 2

#this var for checking ground first, before doing the real velocity
#when standing above moving platform, and moving platform going down, character can't follow the moving platform, so check the ground first
#and if get the moving platform, then add the velocity of moving platform
#always revert the motion by position -= kinematic_col.travel
var ground_check_length = 2

#onready var raycast_left = RayCast2D.new()
#onready var raycast_right = RayCast2D.new()
#
func _ready():
	if WALL_SLIDE_PATH != null:
		WALL_SLIDE = get_node(WALL_SLIDE_PATH)
#	add_child(raycast_left)
#	add_child(raycast_right)
#	raycast_left.global_position = get_center_position() + (Vector2(-1 , 1) * get_shape_size()) + Vector2(get_safe_margin(), -get_safe_margin())
#	raycast_right.global_position = get_center_position() + (Vector2(1, 1) * get_shape_size()) + Vector2(-get_safe_margin(), -get_safe_margin())
#	raycast_left.enabled = true
#	raycast_right.enabled = true

func move():
	#reset
	if is_jumping and is_grounded:
		is_jumping = false
	is_grounded = false
	is_walled = false
	is_ceiled = false
	
	velocity.y += GRAVITY * get_physics_process_delta_time()
	
	horizontal_movement()
	
	var kinematic_col = move_and_collide(velocity)
	
	# Slope handle
	if is_on_slope_angle() and not is_try_jumping and velocity.x != 0:
		#revert the movement
		if kinematic_col:
			position -= kinematic_col.travel
		else:
			position -= velocity

		var check_ground_vel = GRAVITY * get_physics_process_delta_time()
		if check_ground_vel < velocity.y:
			check_ground_vel = velocity.y
		# IMPORTANT!!! : when move_and_collide with Vector2(0, check_ground_vel), the result travel x is not zero, this is weird, don't know bug or not.
		var kinematic_col_slope = move_and_collide(Vector2(0, check_ground_vel))
		
		if kinematic_col_slope:
			position.x -= kinematic_col_slope.travel.x
			var rotation_angle = sign(velocity.x) * 90
			var vel_dir = kinematic_col_slope.normal.rotated(deg2rad(rotation_angle)).normalized() * abs(velocity.x)

			#move along the ground direction
			move_and_collide(vel_dir)
			velocity.y = kinematic_col_slope.travel.y + vel_dir.y
			kinematic_col = kinematic_col_slope
		else:
			#redo the origin movement
			if kinematic_col:
				position += kinematic_col.travel
			else:
				position += velocity
		
	
	
	#reset
	last_ground_normal = Vector2(0,0)
	last_ceil_normal = Vector2(0,0)
	last_wall_normal = Vector2(0,0)
	
	for i in range(bounce_count):
		#collision handle
		if kinematic_col:
			
			var remain = kinematic_col.remainder
			var move_remainder = true
			var floor_angle = rad2deg(abs(kinematic_col.normal.angle_to(Vector2(0, -1))))
			
			# sometimes floor_angle is not detect the right angle, it always says more by 0.000001 - 0.5, so I decided to minus it by 0.1 to make it more neutral 
			if floor_angle - 0.1 < FLOOR_ANGLE:
				last_ground_normal = kinematic_col.normal
				is_grounded = true
				
				#moving on slope
				if kinematic_col.normal != Vector2(0, -1):
					#stop remaining movement
					move_remainder = false
			elif rad2deg(abs(kinematic_col.normal.angle_to(Vector2(0, 1)))) <= FLOOR_ANGLE:
				last_ceil_normal = kinematic_col.normal
				is_ceiled = true
			else:
				last_wall_normal = kinematic_col.normal
				is_walled = true
				#falling slope
				if is_on_falling_slope_angle():
					var rotation_angle = sign(last_wall_normal.x) * 90
					if velocity.y < 0:
						# let it slide
						kinematic_col = move_and_collide(remain.slide(kinematic_col.normal))
					else:
						# let it falling through slope angle
						var vel_dir = last_wall_normal.rotated(deg2rad(rotation_angle)).normalized() * abs(velocity.y)
						kinematic_col = move_and_collide(vel_dir)
					move_remainder = false
				#Wall Slide
				elif (kinematic_col.normal.x == 1 or kinematic_col.normal.x == -1) and WALL_SLIDE and !is_grounded and velocity.y > 0:
					kinematic_col = WALL_SLIDE.wall_sliding(kinematic_col)
					move_remainder = false
				
			
			if move_remainder:
				remain = remain.slide(kinematic_col.normal)
				velocity = velocity.slide(kinematic_col.normal)
				
				kinematic_col = move_and_collide(remain)
			else:
				break
		
	
	move_floor_velocity()
	
	jump_movement()
	
	if velocity.x != 0:
		face_direction = sign(velocity.x)

func horizontal_movement():
	var delta = get_physics_process_delta_time()
	var vel_x = velocity.x
	
	if horizontal_input.axis == 1:
		vel_x += move_step * delta
		if vel_x > MOVE_SPEED:
			vel_x = MOVE_SPEED
	elif horizontal_input.axis == -1:
		vel_x -= move_step * delta
		if vel_x < -MOVE_SPEED:
			vel_x = -MOVE_SPEED
	elif vel_x != 0:
		var stop_dir = sign(vel_x) * -1
		vel_x += stop_dir * stop_step * delta
		if sign(vel_x) == stop_dir:
			vel_x = 0
	
	velocity.x = vel_x

#all kind of jump movement
#included unique jump such a wall jump
func jump_movement():
	#reset
	is_try_jumping = false
	if is_grounded:
		air_jump_count = 0
	
	var delta = get_physics_process_delta_time()
	var vel_y = velocity.y
	
	if jump_just_pressed:
		# regular jump
		if is_grounded and !is_on_falling_slope_angle():
			vel_y = -MAX_JUMP_POWER
		elif is_on_falling_slope_angle():
			velocity = last_wall_normal * MAX_JUMP_POWER
			vel_y = velocity.y
		# jump while wall sliding
		elif is_wall_sliding() and last_wall_normal.x * -1 == horizontal_input.axis:
			WALL_SLIDE.wall_jump()
			vel_y = velocity.y
		# air jump
		elif !is_grounded and air_jump_count < MAX_AIR_JUMP:
			vel_y = -MAX_AIR_JUMP_POWER
			air_jump_count += 1
		is_try_jumping = true
		is_jumping = true
	elif jump_just_released:
		if vel_y < -MIN_JUMP_POWER and air_jump_count == 0:
			vel_y = -MIN_JUMP_POWER
		elif vel_y < -MIN_AIR_JUMP_POWER and air_jump_count > 0:
			vel_y = -MIN_AIR_JUMP_POWER
	
	velocity.y = vel_y
	

func move_floor_velocity():
	var kinematic_col = move_and_collide(Vector2(0, ground_check_length))
	if kinematic_col and not get_is_jumping():
		position -= kinematic_col.travel
		position += kinematic_col.collider_velocity * get_physics_process_delta_time()
		
		if rad2deg(abs(kinematic_col.normal.angle_to(Vector2(0, -1)))) <= FLOOR_ANGLE:
			is_grounded = true
	else:
		position -= Vector2(0, ground_check_length)
	

func play_animation():
	if velocity.x != 0:
		SPRITE.flip_h = face_direction == -1
		if face_direction == -1:
			collider.position = collider_origin_position + FLIP_COLLIDER_OFFSET
		else:
			collider.position = collider_origin_position
	
	var next_anim = "idle"
	if abs(velocity.x) > 0 and is_grounded:
		next_anim = "move"
	elif velocity.y > 0 and is_wall_sliding():
		next_anim = "WallSlide"
	elif not is_grounded:
		next_anim = "jump"

	if ANIM.get_current_animation() != next_anim:
		ANIM.play(next_anim)

func get_is_jumping():
	return is_jumping and not is_grounded

func get_is_falling():
	return velocity.y > 0 and not is_grounded

func is_wall_sliding():
	return WALL_SLIDE and is_walled and velocity.y > 0 and not is_grounded and abs(last_wall_normal.x) == 1

func get_center_position():
	return collider.global_position

func is_on_slope_angle():
	return last_ground_normal != Vector2(0,0) and last_ground_normal != Vector2(0, -1)

func is_on_falling_slope_angle():
	# != Vector2(0,0) make sure touching wall
	# !(last_wall_normal.x == 1 or last_wall_normal.x == -1) make sure not plain wall
	# last_wall_normal.y <= 0 make sure the wall direction is not ceiling
	return last_wall_normal != Vector2(0,0) and !(last_wall_normal.x == 1 or last_wall_normal.x == -1) and last_wall_normal.y <= 0

func get_shape_collision():
	return shape_owner_get_shape(0,0)

#func get_shape_size():
#	if get_shape_collision().is_class("RectangleShape2D"):
#		return get_shape_collision().extents * 2
#	elif get_shape_collision().is_class("CapsuleShape2D"):
#		return Vector2()
#	return Vector2()

class InputAxis:
	var axis = 0
	var pos_action = ""
	var neg_action = ""
	
	func _init(pos, neg):
		pos_action = pos
		neg_action = neg
	
	func update():
		if Input.is_action_pressed(pos_action) and not Input.is_action_pressed(neg_action):
			axis = 1
		elif not Input.is_action_pressed(pos_action) and Input.is_action_pressed(neg_action):
			axis = -1
		else:
			axis = 0