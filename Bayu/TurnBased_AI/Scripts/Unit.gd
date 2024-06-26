class_name Unit
extends CharacterBody2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

@export var player_id := 1

@onready var _sprite = $Sprite2D
@export var _animation_resource: AnimationLibrary
@onready var path = $"../../UnitPath"
@export var _animation_state_machine: AnimationNodeStateMachine
@onready var _animation := $AnimationPlayer
@onready var _animationTree := $AnimationTree

var database : SQLite
var attack_range : int
var current_dir : String
var last_direction := Vector2.ZERO

var _is_idle : bool

## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO:
	set(value):
		cell = value

## Array that contains walking paths.
var walk_coordinates := []:
	set(value):
		walk_coordinates = value

var skin: Texture2D:
	set(value):
		skin = value
		if not _sprite:
			await ready
		_sprite.texture = value

var max_health: float:
	set(value):
		max_health = value * 1.0

var level: int

var curr_health: float:
	get:
		return max_health
	set(value):
		curr_health = clamp(value, 0, max_health)

#setter getter
var nama: String:
	set(value):
		nama = value

var icon: Texture2D:
	set(value):
		icon = value

var inactive_icon: Texture2D:
	set(value):
		inactive_icon = value

var move_range :int
var move_speed :int

var is_selected := false:
	set(value):
		is_selected = value
		if is_selected:
			_sprite.modulate = Color(1, 1, 1)
		else:
			_sprite.modulate = Color(0.70, 0.70, 0.70)

var _is_walking := false:
	set(value):
		_is_walking = value
		#set_process(_is_walking)

var unit_role: String:
	set(value):
		unit_role = value

func _configure() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	database.query("select nama, health, move_speed, move_range, attack_range, icon, inactive_icon, skin, role from Player where player_id = "+ str(player_id))
	for data in database.query_result:
		pass
		nama = data.nama
		max_health = data.health
		move_speed = data.move_speed
		move_range = data.move_range
		attack_range = data.attack_range
		var skin_image = Image.new()
		skin_image.load_png_from_buffer(data.skin)
		var texture = ImageTexture.create_from_image(skin_image)
		var icon_image = Image.new()
		icon_image.load_png_from_buffer(data.icon)
		var icon_data = ImageTexture.create_from_image(icon_image)
		var inactive_icon_image = Image.new()
		inactive_icon_image.load_png_from_buffer(data.inactive_icon)
		var inactive_icon_data = ImageTexture.create_from_image(inactive_icon_image)
		icon = icon_data
		inactive_icon = inactive_icon_data
		skin = texture
		unit_role = data.role

func _ready():
	_configure()
	print(nama, attack_range, unit_role, move_speed, "Current Health: ", curr_health)
	#Configuring AnimationPlayer and AnimationTree
	_animationTree.tree_root = _animation_state_machine
	_animationTree.active = true

func walk():
	_is_walking = true
	_is_idle = false

func _process(delta: float):
	_update_animation_condition()
	_update_blend_position()

	#Process unit walk code
	if walk_coordinates.is_empty():
		_is_walking = false
		_is_idle = true
		emit_signal("walk_finished")

func _physics_process(delta):
		if _is_walking:
			var target_pos = walk_coordinates.front()
			cell = path.local_to_map(target_pos) 
			last_direction = check_direction(target_pos)
			position = position.move_toward(target_pos, move_speed*delta)
			if position == target_pos:
				walk_coordinates.pop_front()

func check_direction(next_tile) -> Vector2:
	var direction_vector = sign(next_tile - global_position)
	return direction_vector

func _update_blend_position() -> void:
	_animationTree["parameters/Idle/blend_position"] = last_direction
	_animationTree["parameters/Walk/blend_position"] = last_direction

func _update_animation_condition() -> void:
	_animationTree["parameters/conditions/is_idle"] = _is_idle
	_animationTree["parameters/conditions/is_walking"] = _is_walking
