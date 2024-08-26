class_name Tank
extends Unit

var hitbox = [
	Vector2(3,-10),
	Vector2(4,-10), 
	Vector2(5,-10),
	Vector2(3,-11),
	Vector2(4,-11),
	Vector2(5,-11),
	Vector2(3,-12),
	Vector2(4,-12),
	Vector2(5,-12)
]

signal lock_unit
@onready var mallaby_attack_state = $FiniteStateMachine/MallabyAttackState
func _ready():
	is_selected = false
	hp_status.visible = false
	armor_status.visible = false
	#Konfigurasi signal dalam FSM#
	#walk_state.walk_finished.connect(fsm.change_state.bind(idle_state))
	#walk_state.walk_finished.connect(on_walk_finished)
	#attack_state.attack_finished.connect(fsm.change_state.bind(idle_state))
	#attack_state.attack_finished.connect(on_attack_finished)
	#attack_state.damage_enter.connect(on_damage_entered)
	await _configure()
	fsm.change_state(idle_state)
	#Configuring AnimationPlayer and AnimationTree
	_animationTree.tree_root = _animation_state_machine
	_animationTree.active = true

func atack_done():
	lock_unit.emit()
	fsm.change_state(idle_state)

func _configure() -> void:
	var gamedata = GameData.load_unit_data(player_id)
	player_id = gamedata.id_unit
	nama = gamedata.nama
	max_health = gamedata.health
	curr_health = max_health
	max_armor = gamedata.armor
	curr_armor = max_armor
	agility = gamedata.agility
	move_range = gamedata.move_range
	attack_range = gamedata.attack_range
	damage = gamedata.damage
	icon = load(gamedata.icon)
	inactive_icon = load(gamedata.inactive_icon)
	skin = load(gamedata.skin)
	unit_role = gamedata.unit_role
	if unit_role == "enemy":
		_sprite.material["shader_parameter/color"] = Color8(224, 79, 83)
	else:
		_sprite.material["shader_parameter/color"] = Color8(255, 255, 255)
 
func _update_blend_position() -> void:
	_animationTree["parameters/attack/blend_position"] = last_direction

func _update_animation_condition() -> void:
	_animationTree["parameters/conditions/is_idle"] = _is_idle
	_animationTree["parameters/conditions/is_attacking"] = _is_attacking

func _process(delta: float):
	hp_status.max_value = max_health
	hp_status.value = curr_health
	armor_status.max_value = max_armor
	armor_status.value = curr_armor
	_update_animation_condition()
	_update_blend_position()
	cell = Vector2(5,-10)
