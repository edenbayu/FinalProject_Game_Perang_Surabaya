class_name LoadingScreen
extends Control

@onready var progress_bar = $Panel/ProgressBar
@onready var text = $Panel/Label

signal loading_screen_has_full_coverage

func _update_progress_bar(new_value : float) -> void:
	progress_bar.value = new_value * 100
	
func _on_load_done() -> void:
	queue_free()

func _ready():
	text.visible = false
	$AnimatedSprite2D.play("running")

func _process(_delta):
	if progress_bar.value >= 100:
		progress_bar.visible = false
		text.visible = true
	
