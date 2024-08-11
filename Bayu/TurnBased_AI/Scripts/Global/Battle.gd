extends Node2D

var active_unit : Unit
var target_attack : Unit
var dmg_type : String

#Attack Code ##
func do_shoot(damage_type: String) -> void:
	dmg_type = damage_type
	attack(active_unit, target_attack)

func set_attack_direction(active_unit: Unit, target: Unit) -> void:
	if target == null:
		return
	
	var attacker_dir = check_direction(target, active_unit)
	active_unit.last_direction = attacker_dir
	print("attack direction: ", active_unit.last_direction)
	
func check_direction(target: Unit, active_unit: Unit) -> Vector2:
	var direction_vector = sign(target.global_position - active_unit.global_position)
	return direction_vector
	
func attack(active_unit: Unit, target: Unit):
	if target == null:
		return
	set_attack_direction(active_unit, target)
	active_unit.attack()

func apply_damage():
	print("damage being applied")
	var attacked_dir = check_direction(active_unit, target_attack)
	target_attack.last_direction = attacked_dir
	var tween : Tween
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(target_attack, "modulate", Color8(224, 133, 124), 0.2)
	tween.tween_property(target_attack, "modulate", Color(1,1,1), 0.2)
	match dmg_type:
		"hp_damage":
			print("attack type :", dmg_type)
			attack_hp(active_unit, target_attack)
		"armor_damage":
			print("attack type :", dmg_type)
			attack_armor(active_unit, target_attack)

func attack_hp(active_unit: Unit, target: Unit):
	var final_damage = clamp(apply_reduction(active_unit.damage, target.curr_armor), 0, active_unit.damage)
	target.curr_health -= final_damage
	display_number(final_damage, Vector2(target.global_position.x, target.global_position.y - 126), dmg_type)

func attack_armor(active_unit: Unit, target: Unit):
	var final_damage = active_unit.damage
	target.curr_armor -= final_damage
	display_number(final_damage, Vector2(target.global_position.x, target.global_position.y - 126), dmg_type)

func apply_reduction(base_damage: int, current_armor: int) -> int:
	var final_damage = base_damage
	if current_armor > 10:
		final_damage -= 4
	elif current_armor >= 7:
		final_damage -= 3
	elif current_armor >= 4:
		final_damage -= 2
	elif current_armor >= 1:
		final_damage -= 1
	else:
		return final_damage
	return final_damage
## End of Attack Code ##

## DISPLAY ATTACK DAMAGE ##
func display_number(value: int, position: Vector2, damage_type: String):
	print("damage should be displayed here!")
	var number = Label.new()
	number.global_position = position
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	match damage_type:
		"hp_damage":
			color = "#E63B60"
		"armor_damage":
			color = "#4895EF"
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 40
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 12
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
