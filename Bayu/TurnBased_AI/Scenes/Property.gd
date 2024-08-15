class_name Property
extends StaticBody2D

@export var cell = Vector2i(8,5)

var nearby_unit = []

func _on_area_2d_body_entered(body):
	var unit = body as Unit
	if not unit:
		return
	self.modulate = Color8(255,255,255, 150)
	nearby_unit.append(unit)


func _on_area_2d_body_exited(body):
	var unit = body as Unit
	if not unit:
		return
	nearby_unit.erase(unit)
	if nearby_unit.is_empty():
		self.modulate = Color8(255,255,255, 255)
