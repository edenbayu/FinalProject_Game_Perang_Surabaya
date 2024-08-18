class_name MallabyAttackState
extends State

signal attack_finished
signal damage_enter
@export var actor: Unit
var target_attack: Unit = null

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	actor._is_attacking = true
	actor._is_idle = false

func _exit_state() -> void:
	set_physics_process(false)
	actor._is_attacking = false
	actor._is_idle = true

