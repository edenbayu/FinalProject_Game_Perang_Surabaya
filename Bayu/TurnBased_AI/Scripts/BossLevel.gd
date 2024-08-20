class_name BossLevel
extends LevelManager

var new_target: Unit = null
@export var spawn: PackedScene

func _on_enemy_turn_started(unit: Unit) -> void:
	active_unit = unit
	if active_unit.player_id == 5:
		player_ui.visible = false
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
		if u.player_id == 5 or u.is_dead:
			continue
		u.agility = 8
		tactics_camera.target = u
		Battle.set_attack_direction(u, new_target)
		Battle.display_ability_text("AGILITY +2", Vector2(u.position.x - 110, u.position.y - 160))
		await get_tree().create_timer(1.5).timeout
	_end_turn()

func spawn_unit() -> void:
	var e = spawn.instantiate()
	enemy.add_child(e)
	turn_based.size.x += 96

func set_mallaby_target() -> Unit:
	return gameboard.get_nearest_neighbor_unit()

func _detect_ally_units() -> void:
	#var sensor = active_unit.get_children()
	var raycast = active_unit.sensor
	for ray in raycast.get_children():
		if ray.is_colliding():
			var detected_unit = ray.get_collider() as Unit
			if detected_unit == new_target:
				detected.append(detected_unit)
			else:
				continue
	if detected.is_empty():
		active_unit.is_within_range = false
	else:
		active_unit.is_within_range = true

func execute_matched_actions(action: String, target: Unit) -> void:
	var target_approach = new_target
	if target_approach == null:
		target_approach = randomize_target_unit()
	#await next_action
	match action:
		"approach":
			await gameboard.approach(active_unit, target_approach)
		"flee":
			await gameboard.flee()
		"reload":
			Battle.reload(active_unit)
			await active_unit.reloaded
		"shoot":
			gameboard.choose_attack_action(active_unit, target)
			var damage_type = Battle.random_damage_type(target)
			Battle.do_shoot(damage_type)
			await active_unit.attack_state.attack_finished
			active_unit.attack_options.hide()
		"rest":
			await gameboard.rest(active_unit)

#func on_unit_die(unit) -> void:
	#_units.erase(unit)
	#_icons.clear()
	#var icon = ui_container.get_children()
	#_reinitialize_icon()
	#for u in _units:
		#if u.is_dead:
			#continue
		#var unit_texture = TurnBasedIcon.new()
		#ui_container.add_child(unit_texture)
		#_icons.append(unit_texture)
		#unit_texture.texture = u.inactive_icon
	#if turn_index >= _units.size() - 1:
		#turn_index -= 1
		#_active_icon()
	#else:
		#_active_icon()
	#gameboard._units.erase(unit.cell)
	#check_game_over(player, enemy)
