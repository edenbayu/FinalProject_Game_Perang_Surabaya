extends Control

@onready var text : RichTextLabel = $MarginContainer/Dialoguebox/AnimatedSprite2D/RichTextLabel
signal enter_gameplay

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/Dialoguebox/AnimatedSprite2D.play("default")
	text.visible_ratio = 0

func _input(event):
	enter_game()

func _process(delta):
	text.visible_ratio += 0.0025

func enter_game() -> void:
	if Input.is_action_pressed("klik_mouse_kiri"):
		enter_gameplay.emit()
		queue_free()
