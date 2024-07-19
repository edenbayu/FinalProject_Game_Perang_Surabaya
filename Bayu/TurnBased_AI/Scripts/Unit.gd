class_name Unit
extends CharacterBody2D

## Emitted when the unit reached the end of a path along which it was walking.
signal enter_walk_state
signal walk_finished
signal data_configured

@export var player_id := 1

@onready var _sprite = $Sprite2D
@export var _animation_resource: AnimationLibrary
@onready var path = $"../../UnitPath"
@export var _animation_state_machine: AnimationNodeStateMachine
@onready var _animation := $AnimationPlayer
@onready var _animationTree := $AnimationTree
@onready var fsm : FiniteStateMachine = $FiniteStateMachine
@onready var idle_state : IdleState = $FiniteStateMachine/IdleState
@onready var walk_state : WalkState = $FiniteStateMachine/WalkState


## Cuma untuk debugging sementara, nanti benerin njih ##
@export var hframe: int:
	set(value):
		hframe = value
		if not _sprite:
			await ready
		_sprite.hframes = value

@export var vframe: int:
	set(value):
		vframe = value
		if not _sprite:
			await ready
		_sprite.vframes = value

var database : SQLite
var attack_range : int
var current_dir : String
var last_direction := Vector2.ZERO

var _is_idle : bool
#Flag that indicates wheter card has been used or not
var innate_card := false
var modular_card := false


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

var level: int

##VARIABLE UNTUK AI DECISION MAKING##
var max_health: float:
	set(value):
		max_health = value * 1.0

var curr_health: float:
	set(value):
		curr_health = clamp(value, 0, max_health)

var is_within_range := false
var is_empty_ammo := false
var innate_done := false
#########################################

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
	_update_card_data()
	database.query("select nama, health, move_speed, move_range, attack_range, icon, inactive_icon, skin, role from Player where player_id = "+ str(player_id))
	for data in database.query_result:
		pass
		nama = data.nama
		max_health = data.health
		curr_health = max_health
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
	emit_signal("data_configured")

func _ready():
	#Konfigurasi signal dalam FSM#
	walk_state.walk_finished.connect(fsm.change_state.bind(idle_state))
	enter_walk_state.connect(fsm.change_state.bind(walk_state))
	_configure()
	#Configuring AnimationPlayer and AnimationTree
	_animationTree.tree_root = _animation_state_machine
	_animationTree.active = true

func walk():
	enter_walk_state.emit()

func activate_ability_cards() -> void:
	innate_card = true
	modular_card = true

func _process(delta: float):
	_update_animation_condition()
	_update_blend_position()

func _physics_process(delta):
	pass

func check_direction(next_tile) -> Vector2:
	var direction_vector = sign(next_tile - global_position)
	return direction_vector

func _update_blend_position() -> void:
	_animationTree["parameters/Idle/blend_position"] = last_direction
	_animationTree["parameters/Walk/blend_position"] = last_direction

func _update_animation_condition() -> void:
	_animationTree["parameters/conditions/is_idle"] = _is_idle
	_animationTree["parameters/conditions/is_walking"] = _is_walking

func _update_card_data() -> void:
	var walk_image = preload("res://Sprites/Ling.png")
	var pba = walk_image.get_image().save_png_to_buffer()
	database.update_rows("Player", "id_card = 2", {"skin" : pba})
