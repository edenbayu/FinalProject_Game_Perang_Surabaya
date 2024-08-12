extends Node2D
class_name Level2Manager

#Singleton variable for active units
static var active_unit: Unit
signal next_action

@export var statusUItexture: Array[Texture2D]
@onready var UI_CONTROLLER = $CanvasLayer/UI/HBoxContainer/HBoxContainer/TurnChanger
@onready var ui_container : HBoxContainer = $CanvasLayer/UI/TurnBasedUI/TurnBasedIcons
@onready var turn_based = $CanvasLayer/UI/TurnBasedUI
@onready var timer: Timer = $Timer
@onready var player = $GameBoard/Player
@onready var enemy = $GameBoard/Enemy
@onready var gameboard : GameBoard = $GameBoard
@onready var tactics_camera : TacticsCamera = $TacticsCamera
@onready var deck : Deck = $CanvasLayer/UI/HBoxContainer/HBoxContainer/Hands
@onready var status_ui : StatusUI = $CanvasLayer/UI/HBoxContainer/HBoxContainer/StatusUI
@onready var player_ui : HBoxContainer = $CanvasLayer/UI/HBoxContainer/HBoxContainer
@onready var path : UnitPath = $GameBoard/UnitPath

signal enemy_turn_started(icon: TextureRect)
signal ally_turn_started

var database : SQLite
var _units := []
var _icons := []
var turn_index := 0
var active_icon : TextureRect
var target = null
var targets = []
var detected := []
var wait_time_test := 1.5

# Called when the node enters the scene tree for the first time.
func _ready():
	_reinitialize()
	#_get_card_informations()
	
	#Change this code later into a more proper way
	turn_based.size.x += (len(ui_container.get_children()) - 1) * ui_container.size.x
	for icon in ui_container.get_children():
		turn_based.position.x -= icon.size.x / 4
	$CanvasLayer.visible = false
	
	for p in player.get_children():
		var unit = p as Unit
		unit.unit_die.connect(on_unit_die)
	for e in enemy.get_children():
		var unit = e as Unit
		unit.unit_die.connect(on_unit_die)
	#active_unit.hp_status.visible = false
	#active_unit.armor_status.visible = false

func _process(delta):
	pass

func set_turn():
	check_game_over(player, enemy)
	var unit_status = _units[turn_index].unit_role
	_active_icon()
	match unit_status:
		"ally":
			emit_signal("ally_turn_started", active_unit)
		"enemy":
			emit_signal("enemy_turn_started", active_unit)

func _reinitialize() -> void:
	_units.clear()
	_icons.clear()
	
	##Getting the move_speed stats from player node
	for child in player.get_children():
		var unit := child as Unit
		if not unit:
			continue
		if unit.is_dead:
			continue
		_units.append(unit)

	##Getting the move_speed stats from enemy node
	for child in enemy.get_children():
		var unit := child as Unit
		if not unit:
			continue
		if unit.is_dead:
			continue
		_units.append(unit)
	_units.sort_custom(_sort_turn)
	#_units[turn_index].is_selected = true
	
	##Adding icon child into the UI container
	for unit in _units:
		var unit_texture = TurnBasedIcon.new()
		ui_container.add_child(unit_texture)
		_icons.append(unit_texture)
		unit_texture.texture = unit.inactive_icon
	_icons[turn_index].is_active = true
	_active_icon()
	#Aktifkan card
	active_unit.innate_card = true
	active_unit.modular_card = true
	configure_status_ui_texture()

func configure_status_ui_texture() -> void:
	match LevelManager.active_unit.player_id:
		1:
			status_ui.texture = statusUItexture[0]
		2:
			status_ui.texture = statusUItexture[1]
		3:
			status_ui.texture = statusUItexture[2]
		

func _reinitialize_icon() -> void:
	for child in ui_container.get_children():
		var icon = child as TextureRect
		if not icon:
			continue
		child.queue_free()

func _sort_turn(a: Unit, b: Unit) -> bool:
	return a.move_speed > b.move_speed

# Signal handler for ally turn started
func _on_ally_turn_started(unit: Unit) -> void:
	deck.clear_hands()
	active_unit = unit
	active_unit.innate_card = true
	active_unit.modular_card = true
	active_unit.is_selected = true
	_get_card_informations()
	print(active_unit.nama)
	configure_status_ui_texture()
	player_ui.visible = true
	deck.reset_card()
	deck.show_card()
	status_ui.reset_card_status()
	await status_ui.status_bar_has_exit
	status_ui.transition_enter()

# Signal handler for enemy turn started
func _on_enemy_turn_started(unit: Unit) -> void:
	active_unit.modular_done = false
	active_unit.innate_done = false
	detected.clear()
	active_unit = unit
	_detect_ally_units()
	active_unit.is_selected = true
	player_ui.visible = false
	#await _detect_ally_units()
	await get_tree().create_timer(0.25).timeout
	await run_action()
	await _detect_ally_units()
	await get_tree().create_timer(0.5).timeout
	#print("innate ", active_unit.innate_done)
	#print("modular ", active_unit.modular_done)
	#print("ammo ", active_unit.is_empty_ammo)
	#print("range ", active_unit.is_within_range)
	await run_action()
	_end_turn()
	#timer.wait_time = wait_time_test
	#timer.start()

func run_action() -> void:
	var target = set_attack_target(detected)
	var action = gameboard.get_first_act(active_unit)
	await execute_matched_actions(action, target)

func execute_matched_actions(action: String, target: Unit) -> void:
	#await next_action
	match action:
		"approach":
			await gameboard.approach(active_unit)
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
			target.attack_options.hide()
			active_unit.modular_done = true
		"rest":
			await gameboard.rest(active_unit)

func _detect_ally_units() -> void:
	var sensor = active_unit.get_children()
	var raycast = sensor.back()
	for ray in raycast.get_children():
		if ray.is_colliding():
			var detected_unit = ray.get_collider() as Unit
			if detected_unit.unit_role == "ally" and detected_unit.curr_health > 0 and not detected_unit.is_dead:
				detected.append(detected_unit)
	if detected.is_empty():
		active_unit.is_within_range = false
	else:
		active_unit.is_within_range = true

func set_attack_target(in_range_target: Array) -> Unit:
	var attack_target = null
	for target in in_range_target:
		if (!attack_target or target.curr_health < target.curr_health) and target.curr_health > 0:
			attack_target = target
	return attack_target

## Function to handle button press (switches to enemy turn)
func _on_button_pressed():
	# Set the turn to enemy turn
	_end_turn()

func _end_turn()-> void:
	deck.on_card_chosen()
	active_icon.texture = active_unit.inactive_icon
	gameboard._deselect_active_unit()
	_units[turn_index].is_selected = false
	_icons[turn_index].is_active = false
	gameboard.target_attack = null
	active_unit = null
	turn_index = (turn_index + 1) % _units.size()
	if turn_index == 0:
		_reinitialize_icon()
		_reinitialize()
		print("new_cycle")
	set_turn()
	status_ui.transition_exit()

func _active_icon() -> void:
	active_unit = _units[turn_index]
	tactics_camera.target = active_unit
	_units[turn_index].is_selected = true
	active_icon = _icons[turn_index]
	active_icon.is_active = true
	if active_icon:
		active_icon.texture = active_unit.icon

func _get_card_informations() -> void:
	#1. Open database connection
	database = SQLite.new()
	database.path = "res://database.db"
	database.open_db()
	
	#2. query the card datas
	database.query("select card.id_card, card_name, texture, back_texture, description, card_ability, card_type 
					from unit_data
					join card on unit_data.id_card = card.id_card
					where unit_data.nama = " + "'" + str(active_unit.nama).to_lower() + "'") 
	
	#3. instantiate card based on query result
	deck.spawn_new_card(database.query_result)
	deck.match_card_functionalities()

##Camera configurations
func _on_zoom_in_pressed() -> void:
	#get_tree().paused = false
	#tactics_camera.zoom_in()
	#await get_tree().create_timer(0.5).timeout
	#get_tree().paused = true
	$GameOver.show()

func _on_exit_button_pressed() -> void:
	#get_tree().paused = true
	#$CanvasLayer.visible = false
	tactics_camera.zoom_out()

func _on_utility_ai_agent_top_score_action_changed(top_action_id):
	next_action.emit()


func _on_interactables_enter_gameplay():
	$CanvasLayer.visible = true
	status_ui.transition_enter()
	_get_card_informations()
	$GameBoard/UnitPath.visible = true
	
func on_unit_die(unit) -> void:
	_units.erase(unit)
	_icons.clear()
	var icon = ui_container.get_children()
	_reinitialize_icon()
	for u in _units:
		if u.is_dead:
			continue
		var unit_texture = TurnBasedIcon.new()
		ui_container.add_child(unit_texture)
		_icons.append(unit_texture)
		unit_texture.texture = u.inactive_icon
	if turn_index >= _units.size() - 1:
		turn_index -= 1
		_active_icon()
	else:
		_active_icon()
	turn_based.size.x -= 96
	gameboard._units.erase(unit.cell)
	check_game_over(player, enemy)

func check_game_over(player, enemy) -> void:
	var all_player_dead = true
	var all_enemies_dead = true
	for unit in player.get_children():
		var u = unit as Unit
		if not u.is_dead:
			all_player_dead = false
			break
	for unit in enemy.get_children():
		var u = unit as Unit
		if not u.is_dead:
			all_enemies_dead = false
			break
	if all_player_dead:
		lose_game()
	elif all_enemies_dead:
		win_game()

func lose_game():
	#await get_tree().create_timer(0.5).timeout
	#get_tree().paused = true
	$GameOver.show()

func win_game():
	#await get_tree().create_timer(0.5).timeout
	#get_tree().paused = true
	$GameOver.show()
