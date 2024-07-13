class_name StatusUI
extends TextureRect

signal status_bar_has_exit
var tween : Tween
@onready var animation : AnimationPlayer = $AnimationPlayer

func _ready():
	transition_enter()

func transition_exit() -> void:
	print("posisi sekarang: ", self.position)
	self.position.x = 0
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2(-577, self.position.y), 2)
	self.position.x = -577
	print(self.position.x)
	if self.position.x <= -500:
		print("emitted signal")
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
