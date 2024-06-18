@tool
extends TextureRect
class_name TurnBasedIcon

var is_active:= false:
	set(value):
		is_active = value
		if is_active:
			self_modulate = Color(1, 1, 1)
		else:
			self_modulate = Color(0.50, 0.50, 0.50)

func _ready():
	is_active = false
