class_name FinalLevel
extends LevelManager

var new_target: Unit = null
const new_targets = []
@export var explosive : PackedScene

func _on_enemy_turn_started(unit: Unit) -> void:
	active_unit = unit
	player_ui.visible = false
	boss_act()

func boss_act() -> void:
	print(active_unit.nama, active_unit.cell)
	print(gameboard._units)
	new_target = set_tank_target()
	set_tank_direction(new_target)
	active_unit.fsm.change_state(active_unit.mallaby_attack_state)
	await active_unit.lock_unit
	tactics_camera.target = new_target
	var e = explosive.instantiate()
	add_child(e)
	e.position = new_target.position
	await get_tree().create_timer(1).timeout
	new_target.curr_health -= 10
	Battle.display_number(10, Vector2(new_target.global_position.x, new_target.global_position.y - 126), "hp_damage")
	_end_turn()

func set_tank_direction(target: Unit) -> void:
	if target.cell.x < 5:
		active_unit.last_direction = Vector2(1,1)
	elif target.cell.x < 10:
		active_unit.last_direction = Vector2(1,0)
	else:
		active_unit.last_direction = Vector2 (-1,-1)

func randomize_target_unit() -> Unit:
	var valid_units = []
	
	for child in player.get_children():
		if child is Unit and child.curr_health > 0 and child.player_id != 1:
			valid_units.append(child)
	if valid_units.is_empty():
		return
	var random_index = randi() % valid_units.size()
	return valid_units[random_index]

func set_tank_target() -> Unit:
	return randomize_target_unit()

func check_game_over(player, enemy) -> void:
	var all_player_dead = true
	for unit in player.get_children():
		var u = unit as Unit
		if u.player_id == 1:
			continue
		if not u.is_dead:
			all_player_dead = false
			break
	if all_player_dead:
		lose_game()

func lose_game():
	$GameOver.visible = true
	$GameOver/AnimationPlayer.play("ending_scene")

func go_to_ending():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
