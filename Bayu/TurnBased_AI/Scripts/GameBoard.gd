class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
@export var property_cells : Array[Vector2] = [Vector2(8,5), Vector2(8,4), Vector2(8,3), 
						Vector2(8,-1), Vector2(8,-2), Vector2(8,-3), 
						Vector2(5,2), Vector2(5,1), Vector2(5,0)]
signal action_done

@export var orientation: String
@export var grid: Grid
@onready var unitPath: UnitPath = $UnitPath
@onready var cursor = $Cursor
@onready var player = $Player
@onready var enemy = $Enemy
@onready var props = $Props
@onready var deck : Deck = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer/Hands"
@onready var status_ui : StatusUI = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer/StatusUI"
var audio = preload("res://Scenes/SoundManager.tscn")
@export var level = 2

var is_within_map: bool
var _walkable_cells := []
var _attack_cells := []
var _units := {}
var selected_ability = null
var selected_type = null
var target_attack :Unit = null

## AI's variables ##
var ai_attack_area := []
var damage_type = null

var _is_clickable := false:
	set(value):
		_is_clickable = value
	

func _ready() -> void:
	audio = audio.instantiate()
	add_child(audio)
	audio.level1_bgm(level)
	_initiallize_unit_pos()
	_reinitialize()
	unitPath.clear_cells(grid)
	_update()
	for p in player.get_children():
		var unit = p as Unit
		unit.damage_enter.connect(Battle.apply_damage)
	for e in enemy.get_children():
		var unit = e as Unit
		unit.damage_enter.connect(Battle.apply_damage)
	Battle.display_text_z_order = 20

func _process(_delta):
	_update()

func get_grid_data(grid_data: Grid) -> Array:
	var cells = []
	for x in range(grid_data.start_rect.x, grid_data.start_rect.x + grid_data.tilemap_size.x):
		for y in range(grid_data.start_rect.y, grid_data.start_rect.y + grid_data.tilemap_size.y):
			cells.append(Vector2(x, y))
	return cells

## Clears, and refills the `_units` dictionary wit	h game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in player.get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
	
	for child in enemy.get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
		

func _initiallize_unit_pos() -> void:
	for child in player.get_children():
		var unit := child as Unit
		if not unit:
			continue
		unit.cell = unitPath.local_to_map(unit.position)
	for child in enemy.get_children():
		var unit := child as Unit
		if not unit:
			continue
		unit.cell = unitPath.local_to_map(unit.position)

func _unhandled_input(event: InputEvent):
	if LevelManager.active_unit and event.is_action("ui_cancel"):
		_deselect_active_unit()
		deck.show_card()

##Function untuk mengecek apakah cursor berada di dalam cell yang aktif
func _check_hoverable_tiles(cell: Vector2) -> void:
	var current_cursor_location: Vector2 = unitPath.local_to_map(cell)
	if unitPath.local_to_map(cell) in unitPath.get_walkable_cells():
		cursor.visible = true
		cursor.position = unitPath.map_to_local(current_cursor_location)
	elif !unitPath.local_to_map(cell) in unitPath.get_walkable_cells():
		cursor.visible = false
	is_within_map = cursor.visible
	#_is_clickable = cursor.visible 

func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	print("HGAHAHA", selected_type)
	if selected_ability == null:
		return
	match selected_ability:
		"Walk":
			choose_walk_cell(cell)
			await LevelManager.active_unit.walk_state.walk_finished
		"Reload":
			_deselect_active_unit()
			Battle.reload(LevelManager.active_unit)
			await LevelManager.active_unit.reloaded
			if not LevelManager.active_unit.modular_done:
				deck.enable_modular_card()
		"Attack":
			choose_attack_action(LevelManager.active_unit, target_attack)
			await LevelManager.active_unit.attack_state.attack_finished
	match selected_type:
		'innate':
			status_ui.burn_innate_card()
			deck.disable_innate_card()
			deck.inactive_innate_ability()
		'modular':
			status_ui.burn_modular_card()
			deck.disable_modular_card()
			deck.inactive_modular_ability()
	deck.show_card()
	selected_ability = null
	selected_type = null
	cursor.is_visible = false

func choose_walk_cell(new_cell: Vector2) -> void:
	var mapped_cell: Vector2 = unitPath.local_to_map(new_cell)
	if is_occupied(mapped_cell) or not mapped_cell in _walkable_cells or object_cell(mapped_cell):
		Battle.display_invalid_tile($"../TacticsCamera".position)
		return
	_move_active_unit(mapped_cell)

func choose_attack_action(active_unit: Unit, target: Unit) -> void:
	if target == null:
		Battle.display_invalid_tile($"../TacticsCamera".position)
		return
	Battle.active_unit = active_unit
	Battle.target_attack = target
	_deselect_active_unit()
	cursor.is_visible = false
	active_unit.attack_options.show()

func on_card_clicked(card_type, card_ability) -> void:
	selected_ability = card_ability
	selected_type = card_type
	deck.on_card_chosen()
	cursor.is_visible = true

## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)

func array_intersection(arr1: Array, arr2: Array) -> Array:
	var intersection = []
	
	for elem in arr1:
		if arr2.has(elem) and not intersection.has(elem):
			intersection.append(elem)
	
	return intersection

func get_attack_range_cells(unit: Unit) -> Array:
	return _flood_fill_attack(unit.cell, unit.attack_range)

## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if current in array:
			continue

		var difference: Vector2i = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates) or is_outside_map(coordinates) or object_cell(coordinates):
				continue
			if coordinates in array:
				continue
			# Minor optimization: If this neighbor is already queued
			#	to be checked, we don't need to queue it again
			if coordinates in stack:
				continue

			stack.append(coordinates)
	array.pop_front()
	return array

## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill_attack(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if current in array:
			continue

		var difference: Vector2i = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_outside_map(coordinates):
				continue
			if coordinates in array:
				continue
			if coordinates in stack:
				continue

			stack.append(coordinates)
	array.pop_front()
	return array

func is_outside_map(cell: Vector2i) -> bool:
	if cell not in unitPath.get_walkable_cells():
		return true
	return false
	
func is_occupied(cell: Vector2) -> bool:
	return _units.has(cell)

func object_cell(cell: Vector2) -> bool:
	return property_cells.has(cell)

##Move active unit based on it's movement area, initializing pathfinding, executing walk function
func _move_active_unit(new_cell: Vector2) -> void:
	#if is_occupied(new_cell) or not new_cell in _walkable_cells or object_cell(new_cell):
		#return
	unitPath.get_walk_path(LevelManager.active_unit.cell, new_cell)
	unitPath.current_path.remove_at(0) #Makes sure that the current path isn't walkable
	var new_path := []
	for i in unitPath.current_path:
		i = unitPath.map_to_local(i)
		new_path.append(i)
	LevelManager.active_unit.walk_coordinates = new_path 
	##Menghapus active unit setelah selesai bergerak
	_units.erase(LevelManager.active_unit.cell)
	_units[new_cell] = LevelManager.active_unit
	_deselect_active_unit()
	LevelManager.active_unit.walk()
	await LevelManager.active_unit.walk_state.walk_finished
	_clear_active_unit()

## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	#LevelManager.active_unit.is_selected = false
	unitPath.clear_cells(grid)

func _clear_active_unit() -> void:
	_walkable_cells.clear()

func _update() -> void:
	var ordering = []
	#Iterate thru the player nodes
	for child in player.get_children():
		var unit := child as Unit
		if not unit:
			continue
		ordering.append(unit)
	#Iterate thru the player nodes
	for child in enemy.get_children():
		var unit := child as Unit
		if not unit:
			continue
		ordering.append(unit)
	##Hardcodeed bisa lebih dirapihin kalau ada waktu
	for child in props.get_children():
		ordering.append(child)
	#ordering.append($Props/TableChair4)
	#ordering.append($Props/TableChair5)
	#ordering.append($Props/TableChair6)

	# Sort units based on their cell values
	isometric_orientation(ordering)
	# Iterate through sorted units and assign Z indices
	for i in range(ordering.size()):
		var unit = ordering[i]
		# Assign Z index based on the index in the sorted list
		unit.z_index = i

func isometric_orientation(ordering: Array):
	match orientation:
		"landscape":
			ordering.sort_custom(_sort_index)
		"portrait":
			ordering.sort_custom(_sort_index_2)
		
func _sort_index(a, b) -> bool:
	if a.cell.y != b.cell.y:
		return a.cell.y < b.cell.y
	else:
		return a.cell.x < b.cell.x

func _sort_index_2(a, b) -> bool:
	if a.cell.x != b.cell.x:
		return a.cell.x < b.cell.x
	else:
		return a.cell.y < b.cell.y

func _on_attack():
	_attack_cells = get_attack_range_cells(LevelManager.active_unit)
	unitPath.display_attack_range(_attack_cells)
	unitPath.initialize(_attack_cells)

func get_weakest_unit() -> Unit:
	var weakest : Unit = null
	for unit in player.get_children():
		var player = unit as Unit
		if not player:
			pass
		if (!weakest or player.curr_health < weakest.curr_health) and player.curr_health > 0:
			weakest = player
	return weakest

#func randomize_target_unit() -> Unit:
	#var valid_units = []
	#
	#for child in player.get_children():
		#if child is Unit and child.curr_health > 0:
			#valid_units.append(child)
	#if valid_units.size() == 0:
		#return
	#var random_index = randi() % valid_units.size()
	#return valid_units[random_index]

func get_path_to_weakest_unit(unit) -> PackedVector2Array:
	var weakest_unit = unit
	#var weakest_unit = get_weakest_unit()
	if weakest_unit == null:
		return []
	var pathfinder = Pathfinder.new(grid, get_grid_data(grid), property_cells)
	var paths = pathfinder.calculate_point_paths(LevelManager.active_unit.cell, weakest_unit.cell)
	paths.remove_at(0)
	return paths

func get_nearest_neighbor_unit():
	var nearest_unit :Unit = null
	var min_distance: int = 100
	for unit in player.get_children():
		var player = unit as Unit
		if not player or player.is_dead:
			pass
		unitPath.initialize(_walkable_cells)
		var  distance: int = unitPath.calculate_distance(LevelManager.active_unit.cell, player.cell)
		if distance < min_distance:
			min_distance = distance
			nearest_unit = player
	return nearest_unit

func testing_card():
	if LevelManager.active_unit.innate_card:
		_walkable_cells = get_walkable_cells(LevelManager.active_unit)
		unitPath.draw(_walkable_cells)
		unitPath.initialize(_walkable_cells)

 ## FUNCTION ACTIONS UNTUK PLAYER ABILITIES ##
func walk():
	pass
	#print("Gooo!")

func innate_reload():
	pass
	#print("show desc of reload")

func reload():
	pass
	#print("buckle up! reloading..")

## SET UP UNTUK ATTACK ##
func set_attack_direction(active_unit: Unit, target: Unit) -> void:
	if target == null:
		return
	var attacker_dir = check_direction(target, active_unit)
	active_unit.last_direction = attacker_dir
	print("attack direction: ", active_unit.last_direction)
	
func check_direction(target: Unit, active_unit: Unit) -> Vector2:
	var direction_vector = sign(target.global_position - active_unit.global_position)
	return direction_vector

func set_target_attack(target) -> void:
	var t = target as Unit
	if not t:
		return
	if _attack_cells.has(t.cell) and t.unit_role == "enemy":
		target_attack = t

func on_target_exited(body):
	target_attack = null

func attack(active_unit: Unit, target: Unit):
	if target == null:
		return
	_deselect_active_unit()
	set_attack_direction(active_unit, target)
	damage_type = "hp_damage"
	active_unit.attack()

func apply_damage():
	var attacked_dir = check_direction(LevelManager.active_unit, target_attack)
	target_attack.last_direction = attacked_dir
	var tween : Tween
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(target_attack, "modulate", Color8(224, 133, 124), 0.2)
	tween.tween_property(target_attack, "modulate", Color(1,1,1), 0.2)
	match damage_type:
		"hp_damage":
			attack_hp(LevelManager.active_unit, target_attack)
		"armor_damage":
			attack_armor(LevelManager.active_unit, target_attack)

func attack_hp(active_unit: Unit, target: Unit):
	var final_damage = clamp(apply_reduction(active_unit.damage, target.curr_armor), 0, active_unit.damage)
	target.curr_health -= 3.0
#### END OF CODE FOR ATTACK ABILITY ###

func attack_armor(active_unit: Unit, target: Unit):
	target.curr_armor -= active_unit.damage

func show_attack():
	if LevelManager.active_unit.modular_card:
		_attack_cells = get_attack_range_cells(LevelManager.active_unit)
		unitPath.display_attack_range(_attack_cells)
		unitPath.initialize(_attack_cells)

func _clear_attack_cells() -> void:
	_attack_cells.clear()

##Code for AI actions##

func _detect_player_unit(cell: Vector2) -> bool:
	var unit_cells = []
	for u in player.get_children():
		var unit = u as Unit
		if not unit:
			continue
		unit_cells.append(unit.cell)
	return unit_cells.has(cell)
	
func _move_active_AI(walk_paths: Array, new_cell) -> void:
	if new_cell == null:
		return
	if is_occupied(new_cell) or not new_cell in walk_paths or object_cell(new_cell):
		return
	var new_path := []
	for i in walk_paths:
		i = unitPath.map_to_local(i)
		new_path.append(i)
	LevelManager.active_unit.walk_coordinates = new_path 
	##Menghapus active unit setelah selesai bergerak
	_units.erase(LevelManager.active_unit.cell)
	_units[new_cell] = LevelManager.active_unit
	_deselect_active_unit()
	LevelManager.active_unit.walk()
	await LevelManager.active_unit.walk_state.walk_finished
	LevelManager.active_unit.innate_done = true
	emit_signal("action_done")
	_clear_active_unit()

#AI actions
func approach(active_unit: Unit, target: Unit) -> void:
	if active_unit == null:
		return
	var path1 = get_path_to_weakest_unit(target)
	var path2 = get_walkable_cells(active_unit)
	var path3 = get_attack_range_cells(active_unit)
	var ai_walk_paths = array_intersection(path1, path2)
	#print("intersection: ", ai_walk_paths, "destination:", ai_walk_paths.back())
	if ai_walk_paths.is_empty():
		return
	var ai_final_target = ai_walk_paths.back()
	await _move_active_AI(ai_walk_paths, ai_final_target)

func get_path_to_flee() -> void:
	var _pathfinder = Pathfinder.new(grid, get_grid_data(grid), property_cells)
	var unit_player_locations = []
	for player_unit in player.get_children():
		var unit = player_unit as Unit
		unit_player_locations.append(unit.cell)
	for cell in unit_player_locations:
		print("arah dari tujuan : ", sign(LevelManager.active_unit.cell - cell))

func flee() -> void:
	print("flee from battle!")

func ai_reload(active_unit: Unit) -> void:
	active_unit.ammo = 3
	active_unit.innate_done = true
	action_done.emit()

func rest(active_unit: Unit) -> void:
	active_unit.modular_done = true
	action_done.emit()
	print("guess i'd do nothin")

#func get_ai_actions():
	#var action = ai_agent.get_top

func get_first_act(active_unit: Unit) -> String:
	var ai_agent = active_unit.get_node("UtilityAiAgent")
	#print("HASHAHA", ai_agent.name)
	return ai_agent._current_top_action

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
