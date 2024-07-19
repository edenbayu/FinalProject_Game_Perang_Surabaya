class_name IdleState
extends State

@export var actor : Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	actor._is_idle = true

func _exite_state() -> void:
	set_physics_process(false)
	actor._is_idle = false
