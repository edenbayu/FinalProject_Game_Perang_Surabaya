class_name Unit
extends CharacterBody2D

#Declares direction for animation
const direction = {
	"down-left": Vector2(0, 1),
	"down-right": Vector2(1, 0),
	"up-right": Vector2(0, -1),
	"up-left": Vector2(-1, 0)
}

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

@export var Data : UnitData

@onready var _sprite = $Sprite2D
@onready var _animation = $AnimationPlayer
@onready var path = $"../../UnitPath"
@onready var _animationTree = $AnimationTree

var attack_range : int
var current_dir : String
var direction_vector: Vector2i: set = check_direction

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
	_animation.play("Idle_FR")
	#_animationTree.active = true

func walk():
	_is_walking = true
	_is_idle = false

func _process(delta: float):
	#print("Is Idle :", _animationTree["parameters/conditions/is_idle"])
	#print("Is Walking :",_animationTree["parameters/conditions/is_walking"])
	_update_blend_position()
	_update_animation_condition()
	#_update_direction(current_dir)
	#print(direction_vector)
	#print(_animationTree["parameters/Idle/blend_position"], _animationTree["parameters/Walk/blend_position"])
	#Process unit walk code
	if walk_coordinates.is_empty():
		_is_walking = false
		_is_idle = true
		emit_signal("walk_finished")
	if _is_walking:
		var target_pos = walk_coordinates.front() 
		cell = path.local_to_map(target_pos)
		var dir = check_direction(cell)
		direction_animator(dir)
		position = position.move_toward(target_pos, move_speed*delta)
		if position == target_pos:
			walk_coordinates.pop_front()
	if _is_idle:
		direction_idle_animator(current_dir)

func direction_animator(dir):
	if dir == "down-left":
		_animation.play("Walk_FL")
	if dir == "down-right":
		_animation.play("Walk_FR")
	if dir == "up-left":
		_animation.play("Walk_BL")
	if dir == "up-right":
		_animation.play("Walk_BR")

func direction_idle_animator(dir):
	if dir == "down-left":
		_animation.play("Idle_FL")
	if dir == "down-right":
		_animation.play("Idle_FR")
	if dir == "up-left":
		_animation.play("Idle_BL")
	if dir == "up-right":
		_animation.play("Idle_BR")

func check_direction(next_tile) -> String:
	var desired_output := Vector2.ZERO
	var current_tile: Vector2 = path.local_to_map(global_position)
	var direction_vector = next_tile - current_tile
	print(direction_vector)
	for dir in direction:
		if direction_vector == direction[dir]:
			current_dir = dir
			return dir
	return "Unknown direction"

#This function to set up animation tree direction parameter
#func _update_direction(current_direction: String) -> void:
	#for dir in direction:
		#if current_direction == dir:
			#direction_vector = direction[dir]

func _update_blend_position() -> void:
	_animationTree["parameters/Idle/blend_position"] = cell
	_animationTree["parameters/Walk/blend_position"] = cell

func _update_animation_condition() -> void:
	_animationTree["parameters/conditions/is_idle"] = _is_idle
	_animationTree["parameters/conditions/is_walking"] = _is_walking
