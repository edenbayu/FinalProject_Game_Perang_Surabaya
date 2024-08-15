class_name RangedUnit
extends Unit

var max_ammo : int
var ammo : int:
	set(value):
		value = clamp(value, 0, max_ammo)
		ammo = value
		if ammo <= 0:
			is_empty_ammo = true
		else:
			is_empty_ammo = false

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
	max_ammo = gamedata.ammo
	ammo = max_ammo
	icon = load(gamedata.icon)
	inactive_icon = load(gamedata.inactive_icon)
	skin = load(gamedata.skin)
	unit_role = gamedata.unit_role
	if unit_role == "enemy":
		_sprite.material["shader_parameter/color"] = Color8(224, 79, 83)
	else:
		_sprite.material["shader_parameter/color"] = Color8(255, 255, 255)
	print("kondisi peluru ", is_empty_ammo, ammo)

func _on_taking_hp_damage():
	attack_options.hide()
	Battle.do_shoot("hp_damage")

func _attack_armor_pressed():
	attack_options.hide()
	Battle.do_shoot("armor_damage")
