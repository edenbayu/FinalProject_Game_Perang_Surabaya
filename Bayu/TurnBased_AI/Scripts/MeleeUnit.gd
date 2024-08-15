class_name MeleeUnit
extends Unit

func _on_taking_hp_damage():
	attack_options.hide()
	Battle.do_melee("hp_damage")

func _attack_armor_pressed():
	attack_options.hide()
	Battle.do_melee("armor_damage")

func _configure() -> void:
	var gamedata = GameData.load_unit_data(player_id)
	player_id = gamedata.id_unit
	nama = gamedata.nama
	max_health = gamedata.health
	curr_health = max_health
	max_armor = gamedata.armor
	curr_armor = max_armor
	agility = gamedata.agility
	move_range = gamedata.move_range
	attack_range = gamedata.attack_range
	damage = gamedata.damage
	icon = load(gamedata.icon)
	inactive_icon = load(gamedata.inactive_icon)
	skin = load(gamedata.skin)
	unit_role = gamedata.unit_role
	if unit_role == "enemy":
		_sprite.material["shader_parameter/color"] = Color8(224, 79, 83)
	else:
		_sprite.material["shader_parameter/color"] = Color8(255, 255, 255)
