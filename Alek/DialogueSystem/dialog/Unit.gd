@tool
extends CharacterBody2D
class_name Bidak

@export var player_data : UnitData
@onready var _sprite := $Sprite2D

var is_stunned := false:
	get:
		return is_stunned
	set(value):
		is_stunned = value

var is_active := false:
	set(value):
		is_active = value
		if is_active:
			_sprite.modulate = Color(1, 1, 1)
		else:
			_sprite.modulate = Color(0.50, 0.50, 0.50)

var nama: String:
	set(value):
		nama = value

var move_speed: float:
	set(value):
		move_speed = value

var unit_role: String:
	set(value):
		unit_role = value

var icon: Texture2D:
	set(value):
		icon = value

func _ready():
	is_active = false
	nama = player_data.nama
	move_speed = player_data.move_speed
	unit_role = player_data.unit_role
	_sprite.texture = player_data.skin
	icon = player_data.icon
