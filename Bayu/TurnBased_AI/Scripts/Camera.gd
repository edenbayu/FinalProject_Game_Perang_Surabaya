extends CharacterBody2D
class_name TacticsCamera

const MOVE_SPEED = 16
const ROT_SPEED = 10

var target = null
var direction = Vector2.ZERO
const speed := 300
var moveable := false

func _ready():
	moveable = true

func follow() -> void:
	if !target: return
	var from = global_transform.origin
	var to = target.global_transform.origin
	var vel = (to-from)*MOVE_SPEED/4
	set_velocity(vel)
	move_and_slide()
	vel = velocity
	if from.distance_to(to) <= 0.25: target = null

func _process(delta):
	follow()

func _physics_process(delta):
	pass
	_move_cam()
	#if moveable:
		#_move_cam()

func _move_cam() -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
