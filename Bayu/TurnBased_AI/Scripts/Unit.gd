class_name Unit
extends CharacterBody2D

## Emitted when the unit reached the end of a path along which it was walking.
signal enter_walk_state
signal data_configured
signal damage_enter
signal enter_attack
signal unit_die(unit)
signal attack_chosen(damage_type)
signal reloaded

const move_speed = 250
@export var player_id := 1

@onready var _sprite = $Sprite2D
@export var _animation_resource: AnimationLibrary
@onready var path = $"../../UnitPath"
@export var _animation_state_machine: AnimationNodeStateMachine
@onready var _animation : AnimationPlayer = $AnimationPlayer
@onready var actions_anim = $ActionAnimations
@onready var _animationTree := $AnimationTree
@onready var fsm : FiniteStateMachine = $FiniteStateMachine
@onready var idle_state : IdleState = $FiniteStateMachine/IdleState
@onready var walk_state : WalkState = $FiniteStateMachine/WalkState
@onready var attack_state = $FiniteStateMachine/AttackState
@onready var hp_status = $Status/HP
@onready var armor_status = $Status/Armor
@onready var attack_options = $AttackIcons
@onready var hp_button = $AttackIcons/Button
@onready var armor_button = $AttackIcons/Button2

### Cuma untuk debugging sementara, nanti benerin njih ##
#@export var hframe: int:
	#set(value):
		#hframe = value
		#if not _sprite:
			#await ready
		#_sprite.hframes = value
#
#@export var vframe: int:
	#set(value):
		#vframe = value
		#if not _sprite:
			#await ready
		#_sprite.vframes = value

var attack_range : int
@export var last_direction := Vector2.ZERO

var _is_idle := false
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

var damage: int

##### VARIABLE UNTUK AI DECISION MAKING #####
var max_health: float:
	set(value):
		max_health = value * 1.0

var max_armor : float
var curr_armor : float:
	set(value):
		curr_armor = clamp(value, 0, max_armor)

var curr_health: float:
	set(value):
		curr_health = clamp(value, 0, max_health)
		if curr_health <= 0:
			is_dead = true
			death()

var is_within_range := false
var is_empty_ammo := false
var innate_done := false
var modular_done := false
var is_dead := false:
	set(value):
		is_dead = value
		if is_dead:
			get_node("CollisionShape2D").disabled = true
		else:
			get_node("CollisionShape2D").disabled = false
var incoming_damage := 0
#############################################

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

#var ammo: int:
	#set(value):
		#ammo = value
		#if ammo <= 0:
			#is_empty_ammo = true
		#else:
			#is_empty_ammo = false

var move_range :int
var agility : int

var is_selected := false:
	set(value):
		is_selected = value
		if is_selected:
			_sprite.modulate = Color(1, 1, 1)
			_sprite.material["shader_parameter/width"] = 3.0
			hp_status.visible = true
			armor_status.visible = true
		else:
			_sprite.modulate = Color(0.5, 0.5, 0.5)
			_sprite.material["shader_parameter/width"] = 0.0
			hp_status.visible = false
			armor_status.visible = false
			
var is_hovered := false:
	set(value):
		is_hovered = value
		if is_hovered:
			_sprite.material["shader_parameter/width"] = 3.0
			_sprite.modulate = Color(1, 1, 1)
			hp_status.visible = true
			armor_status.visible = true
		else:
			_sprite.modulate = Color(0.65, 0.65, 0.65)
			_sprite.material["shader_parameter/width"] = 0.0
			hp_status.visible = false
			armor_status.visible = false
var _is_walking := false:
	set(value):
		_is_walking = value
		#set_process(_is_walking)

var _is_attacking := false

var unit_role: String:
	set(value):
		unit_role = value

func _configure() -> void:
	pass

func _ready():
	is_selected = false
	hp_status.visible = false
	armor_status.visible = false
	#Konfigurasi signal dalam FSM#
	walk_state.walk_finished.connect(fsm.change_state.bind(idle_state))
	walk_state.walk_finished.connect(on_walk_finished)
	attack_state.attack_finished.connect(fsm.change_state.bind(idle_state))
	attack_state.attack_finished.connect(on_attack_finished)
	attack_state.damage_enter.connect(on_damage_entered)
	await _configure()
	fsm.change_state(idle_state)
	#Configuring AnimationPlayer and AnimationTree
	_animationTree.tree_root = _animation_state_machine
	_animationTree.active = true

func walk():
	fsm.change_state(walk_state)

func attack():    
	fsm.change_state(attack_state)

func activate_ability_cards() -> void:
	innate_card = true
	modular_card = true

func _process(delta: float):
	hp_status.max_value = max_health
	hp_status.value = curr_health
	armor_status.max_value = max_armor
	armor_status.value = curr_armor
	_update_animation_condition()
	_update_blend_position()

func on_walk_finished():
	innate_done = true

func on_attack_finished() -> void:
	modular_done = true

func reload_done() -> void:
	innate_done = true
	reloaded.emit()

func on_damage_entered():
	emit_signal("damage_enter")

func check_direction(next_tile) -> Vector2:
	var direction_vector = sign(next_tile - global_position)
	return direction_vector

func _update_blend_position() -> void:
	_animationTree["parameters/Idle/blend_position"] = last_direction
	_animationTree["parameters/Walk/blend_position"] = last_direction
	_animationTree["parameters/Attack/blend_position"] = last_direction
func _update_animation_condition() -> void:
	_animationTree["parameters/conditions/is_idle"] = _is_idle
	_animationTree["parameters/conditions/is_walking"] = _is_walking
	_animationTree["parameters/conditions/is_attacking"] = _is_attacking

func death() -> void:
	var tween : Tween
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate", Color8(255, 255, 255, 0), 1)
	unit_die.emit(self)

func spawn() -> void:
	var tween : Tween
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "modulate", Color8(255, 255, 255, 255), 1)

func _on_taking_hp_damage():
	print("working just fine")

func _attack_armor_pressed():
	print("me either")
