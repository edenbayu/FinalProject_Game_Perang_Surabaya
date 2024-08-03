class_name WalkState
extends State

signal walk_finished
@export var actor: Unit

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	actor._is_walking = true
	actor._is_idle = false

func _exit_state() -> void:
	set_physics_process(false)
	actor._is_walking = false
	actor._is_idle = true

func _physics_process(delta) -> void:
	if actor._is_walking:
		var target_pos = actor.walk_coordinates.front()
		actor.cell = actor.path.local_to_map(target_pos)
		actor.last_direction = actor.check_direction(target_pos)
		actor.position = actor.position.move_toward(target_pos, actor.move_speed*delta)
		if actor.position == target_pos:
			actor.walk_coordinates.pop_front()
	if actor.walk_coordinates.is_empty():
		emit_signal("walk_finished")
