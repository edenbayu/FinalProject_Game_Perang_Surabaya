extends Area2D

@onready var unit_status := $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect"
@onready var hp_bar = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/HP_Bar"
@onready var hp_label = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/HP_Bar/HP_label"
@onready var armor_bar = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/Armor_Bar"
@onready var armor_label = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/Armor_Bar/Label"
@onready var damage = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/Damage"
@onready var agility = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer2/TextureRect/Agility"

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
	if show:
		hp_bar.max_value = show.max_health
		armor_bar.max_value = show.max_armor
		hp_bar.value = show.curr_health
		armor_bar.value = show.curr_armor
		hp_label.text = str(show.curr_health) + "/" + str(show.max_health)
		armor_label.text = str(show.curr_armor) + "/" + str(show.max_armor)
		damage.text = str(show.damage)
		agility.text = str(show.agility)
		unit_status.visible = true
		show.is_hovered = true

func _on_body_exited(body):
	var show = body as Unit
	if not show:
		return
	if show:
		unit_status.visible = false
		if not show == LevelManager.active_unit:
			show.is_hovered = false
