class_name IdleState
extends State

@export var actor : Unit

# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	actor._is_idle = true
	set_physics_process(true)

func _exite_state() -> void:
	actor._is_idle = false
	set_physics_process(false)

