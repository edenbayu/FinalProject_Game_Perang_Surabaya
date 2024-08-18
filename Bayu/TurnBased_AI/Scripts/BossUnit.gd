class_name BossUnit
extends Unit

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

func skill_done():
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
	pass

func _update_animation_condition() -> void:
	_animationTree["parameters/conditions/is_idle"] = _is_idle
	_animationTree["parameters/conditions/is_attacking"] = _is_attacking
