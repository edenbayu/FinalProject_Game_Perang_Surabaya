class_name IdleState
extends State


# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	print(LevelManager.active_unit, "has just entered it's idle state")

func _exite_state() -> void:
	set_physics_process(false)

#func _physics_process(delta):
	#print(LevelManager.active_unit.nama)
