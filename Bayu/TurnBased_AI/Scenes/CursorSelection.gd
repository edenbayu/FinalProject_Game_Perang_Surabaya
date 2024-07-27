extends Area2D

@onready var unit_status := $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect"
@onready var hp_bar  := $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/ProgressBar"
@onready var hp_label := $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/ProgressBar/HP"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_global_mouse_position()

func _show_enemy_status() -> void:
	pass

func _on_body_entered(body) -> void:
	var show = body as Unit
	if not show:
		return
	if show.unit_role == "enemy":
		hp_bar.value = show.curr_health
		hp_bar.max_value = show.max_health
		hp_label.text = str(hp_bar.value) + "/" + str(hp_bar.max_value)
		unit_status.visible = true

func _on_body_exited(body):
	unit_status.visible = false
