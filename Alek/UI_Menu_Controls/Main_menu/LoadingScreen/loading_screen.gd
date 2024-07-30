class_name LoadingScreen
extends Control

@onready var progress_bar = $Panel/ProgressBar
@onready var text = $Panel/Label

signal loading_screen_has_full_coverage

func _update_progress_bar(new_value : float) -> void:
	print("value: ", new_value, progress_bar.value)
	progress_bar.value = new_value * 100
	
func _star_outro_animation() -> void:
	pass

func _ready():
	text.visible = false
	$AnimatedSprite2D.play("running")

func _process(_delta):
	if progress_bar.value >= 100:
		progress_bar.visible = false
		text.visible = true
	
