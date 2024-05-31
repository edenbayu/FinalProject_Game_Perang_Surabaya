extends CharacterBody2D
class_name TacticsCamera

const MOVE_SPEED = 16
const ROT_SPEED = 10

var target = null

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
