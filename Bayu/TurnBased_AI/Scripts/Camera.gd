extends CharacterBody2D
class_name TacticsCamera

const MOVE_SPEED = 16
const ROT_SPEED = 10

@onready var cam : Camera2D = $Node2D/Camera2D
var tween : Tween
var target = null
var direction = Vector2.ZERO
const speed := 600
var moveable := false
var zoomed_in := false

func _ready():
	zoom_in()
	moveable = true

func follow() -> void:
	if !target: return
	var from = global_transform.origin
	var to = target.global_transform.origin
	var vel = (to-from)*MOVE_SPEED/4
	set_velocity(vel)
	move_and_slide()
	vel = velocity
	#if from.distance_to(to) <= 0.25: target = null

func zoom_in() -> void:
	zoomed_in = true
	tween = create_tween().set_ease(Tween.EASE_IN).set_parallel(true)
	tween.tween_property(cam, "zoom", Vector2(1, 1), 0.8)
	tween.tween_property(self, "position", Vector2(self.position.x, self.position.y), 0.0001)

func zoom_out() -> void:
	zoomed_in = false
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel(true)
	tween.tween_property(cam, "zoom", Vector2(0.667, 0.667), 0.8)
	tween.tween_property(self, "position", Vector2(168, 124), 0.8)

func _process(delta):
	pass

func _physics_process(delta):
	if zoomed_in:
		target = LevelManager.active_unit
	else:
		target = null
	follow()
	if moveable:
		_move_cam()

func _move_cam() -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
