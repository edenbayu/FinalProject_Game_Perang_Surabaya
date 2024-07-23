class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

@export var grid: Grid
@onready var unitPath: UnitPath = $UnitPath
@onready var cursor = $Cursor
@onready var player = $Player
@onready var enemy = $Enemy
@onready var ai_agent : UtilityAiAgent = $Enemy/UtilityAiAgent
@onready var deck : Deck = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer/Hands"
@onready var status_ui : StatusUI = $"../CanvasLayer/UI/HBoxContainer/HBoxContainer/StatusUI"

var is_within_map: bool
var _walkable_cells := []
var _attack_cells := []
var _units := {}
var selected_ability = null
var selected_type = null

## AI's variables ##
var ai_attack_area := []

var _is_clickable := false:
	set(value):
		_is_clickable = value
	

func _ready() -> void:
	_initiallize_unit_pos()
	_reinitialize()
	unitPath.clear_cells(grid)
	_update()

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
		_clear_active_unit()

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
	var mapped_cell: Vector2 = unitPath.local_to_map(cell)
	if selected_ability == null:
		return
	match selected_ability:
		"Walk":
			_move_active_unit(mapped_cell)
		"Reload":
			reload()
		"Attack":
			attack()
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
			if is_occupied(coordinates) or is_outside_map(coordinates):
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

##Move active unit based on it's movement area, initializing pathfinding, executing walk function
func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
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
	# Sort units based on their cell values
	ordering.sort_custom(_sort_index)
	# Iterate through sorted units and assign Z indices
	for i in range(ordering.size()):
		var unit = ordering[i]
		# Assign Z index based on the index in the sorted list
		unit.z_index = i

func _sort_index(a: Unit, b: Unit) -> bool:
	if a.cell.y != b.cell.y:
		return a.cell.y < b.cell.y
	else:
		return a.cell.x < b.cell.x

func _on_attack():
	_attack_cells = get_attack_range_cells(LevelManager.active_unit)
	unitPath.display_attack_range(_attack_cells)
	unitPath.initialize(_attack_cells)
	#for target in _attack_cells:
		#var unit := target as Unit
		#if not unit:
			#continue

func get_weakest_unit() -> Unit:
	var weakest : Unit = null
	for unit in player.get_children():
		var player = unit as Unit
		if not player:
			pass
		if (!weakest or player.curr_health < weakest.curr_health) and player.curr_health > 0:
			weakest = player
	return weakest

func get_path_to_weakest_unit() -> PackedVector2Array:
	var weakest_unit = get_weakest_unit()
	var pathfinder = Pathfinder.new(grid, get_grid_data(grid))
	var paths = pathfinder.calculate_point_paths(LevelManager.active_unit.cell, weakest_unit.cell)
	paths.remove_at(0)
	return paths

func get_nearest_neighbor_unit():
	var nearest_unit :Unit = null
	var min_distance: int = 100
	for unit in player.get_children():
		var player = unit as Unit
		if not player:
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

func walk():
	pass
	#print("Gooo!")

func innate_reload():
	pass
	#print("show desc of reload")

func reload():
	pass
	#print("buckle up! reloading..")

func attack():
	_deselect_active_unit()
	#print("show desc of attack")

func show_attack():
	if LevelManager.active_unit.modular_card:
		_attack_cells = get_attack_range_cells(LevelManager.active_unit)
		unitPath.display_attack_range(_attack_cells)
		unitPath.initialize(_attack_cells)

func _clear_attack_cells() -> void:
	_attack_cells.clear()

##Code for AI actions##
func initialize_AI_area_attack() -> void:
	ai_attack_area = get_attack_range_cells(LevelManager.active_unit)
	var enemyDetected = false

	for cell in ai_attack_area:
		if _detect_player_unit(cell):
			enemyDetected = true
			break  # Exit the loop early if an enemy is found
	LevelManager.active_unit.is_within_range = enemyDetected
	print("Enemy sensor within area: ", LevelManager.active_unit.is_within_range)

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
	if is_occupied(new_cell) or not new_cell in walk_paths:
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
	_clear_active_unit()

#AI actions
func approach() -> void:
	var path1 = get_path_to_weakest_unit()
	var path2 = get_walkable_cells(LevelManager.active_unit)
	var ai_walk_paths = array_intersection(path1, path2)
	var ai_final_target = ai_walk_paths.back()
	if not LevelManager.active_unit.is_within_range:
		_move_active_AI(ai_walk_paths, ai_final_target)

func flee() -> void:
	print("flee from battle!")

func ai_reload() -> void:
	print("rilodin!")

func shoot() -> void:
	print("be shootin yer hed!")

func rest() -> void:
	print("guess i'd do nothin")

func get_ai_actions():
	var action = ai_agent.get_top
func _on_utility_ai_agent_top_score_action_changed(top_action_id):
	pass
