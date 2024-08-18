class_name BossLevel
extends LevelManager

var new_target: Unit = null

func _on_enemy_turn_started(unit: Unit) -> void:
	active_unit = unit
	print("i should be acting now!")
	if active_unit.player_id == 5:
		print("boss act")
		boss_act()
	else:
		active_unit.modular_done = false
		active_unit.innate_done = false
		detected.clear()
		_detect_ally_units()
		active_unit.is_selected = true
		player_ui.visible = false
		await get_tree().create_timer(0.25).timeout
		await run_action()
		await _detect_ally_units()
		await get_tree().create_timer(0.5).timeout
		await run_action()
		_end_turn()

func boss_act() -> void:
	active_unit.fsm.change_state(active_unit.mallaby_attack_state)
	await active_unit.lock_unit
	new_target = set_mallaby_target()
	tactics_camera.target = new_target
	await get_tree().create_timer(1).timeout
	for unit in enemy.get_children():
		var u = unit as Unit
		if u.player_id == 5:
			continue
		u.agility = 8
		tactics_camera.target = u
		Battle.display_ability_text("AGILITY +2", Vector2(u.position.x - 110, u.position.y - 160))
		await get_tree().create_timer(1.5).timeout
	_end_turn()

func set_mallaby_target() -> Unit:
	return gameboard.get_nearest_neighbor_unit()

#func _detect_ally_units() -> void:
	#var sensor = active_unit.get_children()
	#var raycast = sensor.back()
	#for ray in raycast.get_children():
		#if ray.is_colliding():
			#var detected_unit = ray.get_collider() as Unit
			#if detected_unit == new_target:
				#detected.append(detected_unit)
	#if detected.is_empty():
		#active_unit.is_within_range = false
	#else:
		#active_unit.is_within_range = true
