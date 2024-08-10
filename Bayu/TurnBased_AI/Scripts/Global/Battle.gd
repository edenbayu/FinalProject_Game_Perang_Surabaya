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

func attack_armor(active_unit: Unit, target: Unit):
	target.curr_armor -= active_unit.damage

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
