class_name StatusUI
extends TextureRect

signal status_bar_has_exit
var tween : Tween
@onready var animation : AnimationPlayer = $AnimationPlayer
@onready var hp_text : Label = $HealthBar/HPText
@onready var armor_text = $ArmorBar/ArmorText

func _ready():
	transition_enter()

func _process(delta):
	$HealthBar.max_value = LevelManager.active_unit.max_health
	$HealthBar.value = LevelManager.active_unit.curr_health
	$ArmorBar.max_value = LevelManager.active_unit.max_armor
	$ArmorBar.value = LevelManager.active_unit.curr_armor
	hp_text.text = str(LevelManager.active_unit.curr_health) + "/" + str(LevelManager.active_unit.max_health)
	armor_text.text = str(LevelManager.active_unit.curr_armor) + "/" + str(LevelManager.active_unit.max_armor)

func transition_exit() -> void:
	self.position.x = 0
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2(-577, self.position.y), 2)
	self.position.x = -577
	if self.position.x <= -500:
		status_bar_has_exit.emit()

func transition_enter() -> void:
	self.position.x = -577
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2(0, self.position.y), 2)

func burn_innate_card() -> void:
	animation.play("burn_innate_card")

func card_burned() -> void:
	get_node("Ability/Innate").visible = false

func burn_modular_card() -> void:
	animation.play("burn_modular_card")

func modular_card_finish_burned() -> void:
	get_node("Ability/Modular").visible = false

func reset_card_status() -> void:
	get_node("Ability/Innate").material["shader_parameter/dissolve_value"] = 1
	get_node("Ability/Modular").material["shader_parameter/dissolve_value"] = 1
	get_node("Ability/Innate").visible = true
	get_node("Ability/Modular").visible = true
