extends Node2D
class_name LevelManager

#var turnManager = TurnManager.new()
@onready var UI_CONTROLLER = $Control/Button
@onready var ui_container = $Control/TurnBasedUI/TurnBasedIcons
@onready var label = $Control/Label
@onready var timer = $Timer
@onready var player = $GameBoard/Player
@onready var enemy = $GameBoard/Enemy
@onready var gameboard = $GameBoard
@onready var camera = $Camera2D

signal enemy_turn_started(icon: TextureRect)
signal ally_turn_started
signal turn_changed

var _units := []
var _icons := []
var _active_unit: Unit
var turn_index := 0
var active_icon : TextureRect

var wait_time_test := 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_reinitialize()
	gameboard._select_unit(_active_unit)
	label.text = "It's your turn: " + str(_units[turn_index].nama)

func set_turn():
	var unit_status = _units[turn_index].unit_role
	_active_icon()
	if unit_status == "ally":
		emit_signal("ally_turn_started", _active_unit)
	elif unit_status == "enemy":
		emit_signal("enemy_turn_started", _active_unit)

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
	gameboard._select_unit(unit)
	label.text = "It's your turn: " + str(unit.nama)
	UI_CONTROLLER.visible = true

# Signal handler for enemy turn started
func _on_enemy_turn_started(unit: Unit) -> void:
	label.text = "It's your enemy turn: " + str(unit.nama)
	UI_CONTROLLER.visible = false
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
	active_icon.texture = _active_unit.inactive_icon
	_units[turn_index].is_selected = false
	_icons[turn_index].is_active = false
	turn_index = (turn_index + 1) % _units.size()
	emit_signal("turn_changed")
	if turn_index == 0:
		_reinitialize_icon()
		_reinitialize()
		print("new_cycle")
	set_turn()

func _active_icon() -> void:
	_active_unit = _units[turn_index]
	_active_unit.is_selected = true
	active_icon = _icons[turn_index]
	active_icon.is_active = true
	if active_icon:
		active_icon.texture = _active_unit.icon
