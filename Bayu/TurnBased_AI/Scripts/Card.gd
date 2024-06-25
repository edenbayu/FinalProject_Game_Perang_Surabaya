class_name Card
extends Button

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export_enum("Walk", "Innate", "Attack") var card_type: String = "Walk"
@export var card_attribute: int
@export var card_texture : Texture2D:
	set(value):
		card_texture = value
		if not _texture:
			await ready
		_texture.texture = value

var tween_rot: Tween
var tween_hover: Tween
var tween_destroy: Tween
var tween_handle: Tween

signal card_chose

@onready var _texture := $CardTexture
# Called when the node enters the scene tree for the first time.
func _ready():
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_gui_input(event: InputEvent) -> void:
	_texture.z_index = 2
	#
	handle_mouse_click(event)
	# Don't compute rotation when moving the card
	if not event is InputEventMouseMotion: return
	
	# Handles rotation
	# Get local mouse pos
	var mouse_pos: Vector2 = get_local_mouse_position()
	#print("Mouse: ", mouse_pos)
	var diff: Vector2 = (position + size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	#print("Lerp val x: ", lerp_val_x)
	#print("lerp val y: ", lerp_val_y)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	#print("Rot x: ", rot_x)
	#print("Rot y: ", rot_y)
	
	self._texture.material.set_shader_parameter("x_rot", rot_y)
	self._texture.material.set_shader_parameter("y_rot", rot_x)

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	
	if event.is_pressed() and not disabled:
		disabled = true
		emit_signal("card_chose")

		
func _on_mouse_entered() -> void:
	$Description.visible = true
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_parallel(true)
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	tween_hover.tween_property(self, "position", Vector2(self.position.x, -80), 0.5)

func _on_mouse_exited() -> void:
	$Description.visible = false
	self.position.y = 0
	_texture.z_index = 0
	
	# Reset rotation
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(_texture.material, "shader_parameter/x_rot", 0.0, 0.5)
	tween_rot.tween_property(_texture.material, "shader_parameter/y_rot", 0.0, 0.5)
	
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
	
