@tool
class_name Unit
extends CharacterBody2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

@export var Data : UnitData

@onready var _sprite = $Sprite2D
@onready var _animation = $AnimationPlayer
@onready var path = $"../../UnitPath"

var attack_range : int

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
		set_process(_is_walking)

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
	_animation.play("Idle")

func walk(new_cell: Vector2):
	_is_walking = true

func _process(delta: float):
	#Process unit walk code
	if walk_coordinates.is_empty():
		_is_walking = false
		emit_signal("walk_finished")
	if _is_walking:
		var target_pos = walk_coordinates.front() 
		cell = path.local_to_map(target_pos)
		position = position.move_toward(target_pos, move_speed*delta)
		if position == target_pos:
			walk_coordinates.pop_front()
