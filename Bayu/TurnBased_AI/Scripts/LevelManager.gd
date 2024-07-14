extends Node2D
class_name LevelManager

#Singleton variable for active units
static var active_unit: Unit

#var turnManager = TurnManager.new()
@onready var UI_CONTROLLER = $CanvasLayer/UI/TurnChanger
@onready var ui_container : HBoxContainer = $CanvasLayer/UI/TurnBasedUI/TurnBasedIcons
@onready var turn_based = $CanvasLayer/UI/TurnBasedUI
@onready var label = $CanvasLayer/UI/Label
@onready var timer: Timer = $Timer
@onready var player = $GameBoard/Player
@onready var enemy = $GameBoard/Enemy
@onready var gameboard : GameBoard = $GameBoard
@onready var tactics_camera : TacticsCamera = $TacticsCamera
@onready var deck : Deck = $CanvasLayer/Deck
@onready var status_ui : StatusUI = $CanvasLayer/UI/StatusUI

signal enemy_turn_started(icon: TextureRect)
signal ally_turn_started
signal turn_changed

var database : SQLite
var _units := []
var _icons := []
var turn_index := 0
var active_icon : TextureRect

var wait_time_test := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_reinitialize()
	_get_card_informations()
	
	#Change this code later into a more proper way
	turn_based.size.x += (len(ui_container.get_children()) - 1) * ui_container.size.x
	for icon in ui_container.get_children():
		turn_based.position.x -= icon.size.x / 2
	label.text = "It's your turn: " + str(_units[turn_index].nama)

func _process(delta):
	pass

func set_turn():
	var unit_status = _units[turn_index].unit_role
	_active_icon()
	if unit_status == "ally":
		emit_signal("ally_turn_started", active_unit)
	elif unit_status == "enemy":
		emit_signal("enemy_turn_started", active_unit)

func _reinitialize() -> void:
	_units.clear()
	_icons.clear()
	
	##Getting the move_speed stats from player node
	for child in player.get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units.append(unit)

	##Getting the move_speed stats from enemy node
	for child in enemy.get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units.append(unit)
	_units.sort_custom(_sort_turn)
	_units[turn_index].is_selected = true
	
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
	print("aktif unit: ", LevelManager.active_unit)

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
	active_unit = unit
	active_unit.innate_card = true
	active_unit.modular_card = true
	active_unit.is_selected = true
	label.text = "It's your turn: " + str(unit.nama)
	UI_CONTROLLER.visible = true
	deck.reset_card()
	deck.show_card()
	status_ui.reset_card_status()
	await status_ui.status_bar_has_exit
	status_ui.transition_enter()

# Signal handler for enemy turn started
func _on_enemy_turn_started(unit: Unit) -> void:
	active_unit = unit
	active_unit.is_selected = true
	label.text = "It's your enemy turn: " + str(unit.nama)
	UI_CONTROLLER.visible = false
	gameboard.get_nearest_neighbor_unit()
	gameboard.get_lowest_hp_unit()
	timer.wait_time = wait_time_test
	timer.start()

## Function to handle button press (switches to enemy turn)
func _on_button_pressed():
	# Set the turn to enemy turn
	_end_turn()

func _on_timer_timeout():
	timer.stop()
	_end_turn()

func _end_turn()-> void:
	deck.on_card_chosen()
	active_icon.texture = active_unit.inactive_icon
	_units[turn_index].is_selected = false
	_icons[turn_index].is_active = false
	active_unit = null
	turn_index = (turn_index + 1) % _units.size()
	emit_signal("turn_changed")
	if turn_index == 0:
		_reinitialize_icon()
		_reinitialize()
		print("new_cycle")
	set_turn()
	status_ui.transition_exit()

func _active_icon() -> void:
	active_unit = _units[turn_index]
	tactics_camera.target = active_unit
	active_unit.is_selected = true
	active_icon = _icons[turn_index]
	active_icon.is_active = true
	if active_icon:
		active_icon.texture = active_unit.icon

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _get_card_informations() -> void:
	#1. Open database connection
	database = SQLite.new()
	database.path = "res://database.db"
	database.open_db()
	
	#2. query the card datas
	database.query("select card.id_card, card_name, texture, back_texture, description, card_ability, card_type 
					from unit_data
					join card on unit_data.id_unit = card.id_card
					where unit_data.nama = " + "'" + str(active_unit.nama).to_lower() + "'") 
	
	#3. instantiate card based on query result
	deck.spawn_new_card(database.query_result)
	deck.match_card_functionalities()
	#_update_card_data()
#
#func _update_card_data() -> void:
	#var walk_image = preload("res://UI/Cards/reload_revamped.png")
	#var pba = walk_image.get_image().save_png_to_buffer()
	#database.update_rows("card", "id_card = 2", {"texture" : pba})
