class_name Unit
extends CharacterBody2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

@export var Data : UnitData

@onready var _sprite = $Sprite2D
@export var _animation_resource: AnimationLibrary
@onready var path = $"../../UnitPath"
@export var _animation_state_machine: AnimationNodeStateMachine
@onready var _animation := $AnimationPlayer
@onready var _animationTree := $AnimationTree

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

func _ready():
	nama = Data.unit_name
	_sprite.texture = Data.skin
	move_range = Data.move_range
	attack_range = Data.attack_range
	move_speed = Data.move_speed
	inactive_icon = Data.inactive_icon
	unit_role = Data.unit_role
	icon = Data.icon
	
	#Configuring AnimationPlayer and AnimationTree
	#_animation.add_animation_library(nama+"_animation", _animation_resource)
	_animationTree.tree_root = _animation_state_machine
	_animationTree.active = true

func walk():
	_is_walking = true
	_is_idle = false

func _process(delta: float):
	print(last_direction)
	_update_animation_condition()
	_update_blend_position()

	#Process unit walk code
	if walk_coordinates.is_empty():
		_is_walking = false
		_is_idle = true
		emit_signal("walk_finished")

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
