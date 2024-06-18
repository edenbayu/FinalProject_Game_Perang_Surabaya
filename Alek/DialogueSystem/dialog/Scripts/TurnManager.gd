@tool 
extends Node2D

#var turnManager = TurnManager.new()
@onready var UI_CONTROLLER = $Control/Button
@onready var ui_container = $Control/HBoxContainer
@onready var label = $Control/Label
@onready var timer = $Timer
@onready var player = $Player
@onready var enemy = $Enemy

enum {ALLY_TURN, ENEMY_TURN}

signal enemy_turn_started(icon: TextureRect)
signal ally_turn_started
signal turn_changed

var _units := []
var _icons := []
var _active_unit: Bidak
var turn_index := 0
var active_icon : TextureRect

var wait_time_test := 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_reinitialize()
	label.text = "It's your turn: " + str(_units[turn_index].nama)

func set_turn():
	var unit_status = _units[turn_index].unit_role
	_units[turn_index].is_active = true
	_icons[turn_index].is_active = true
	if unit_status == "ally":
		emit_signal("ally_turn_started", _units[turn_index])
	elif unit_status == "enemy":
		emit_signal("enemy_turn_started", _units[turn_index])

func _reinitialize() -> void:
	_units.clear()
	_icons.clear()
	#ui_container.get_children().
	##Getting the move_speed stats from player node
	for child in player.get_children():
		var unit := child as Bidak
		if not unit:
			continue
		_units.append(unit)

	##Getting the move_speed stats from enemy node
	for child in enemy.get_children():
		var unit := child as Bidak
		if not unit:
			continue
		_units.append(unit)
	_units.sort_custom(_sort_turn)
	_units[turn_index].is_active = true
	
	#Adding icon child into the UI container
	for unit in _units:
		var unit_texture = TurnBasedIcon.new()
		ui_container.add_child(unit_texture)
		_icons.append(unit_texture)
		unit_texture.texture = unit.icon
	_icons[turn_index].is_active = true
	print(_units)

func _reinitialize_icon() -> void:
	for child in ui_container.get_children():
		var icon = child as TextureRect
		if not icon:
			continue
		child.queue_free()

func _sort_turn(a: Bidak, b: Bidak) -> bool:
	return a.move_speed > b.move_speed

# Signal handler for ally turn started
func _on_ally_turn_started(unit: Bidak) -> void:
	print("It's your turn! Unit:", unit.nama)
	label.text = "It's your turn: " + str(unit.nama)
	UI_CONTROLLER.visible = true

# Signal handler for enemy turn started
func _on_enemy_turn_started(unit: Bidak) -> void:
	var ling = $Player/Ling
	ling.move_speed -= 2
	print("It's enemy's turn! Unit:", unit.nama)
	label.text = "It's your enemy turn: " + str(unit.nama)
	UI_CONTROLLER.visible = false
	timer.wait_time = wait_time_test
	timer.start()

# Function to handle button press (switches to enemy turn)
func _on_button_pressed():
	# Set the turn to enemy turn
	_end_turn()

func _on_timer_timeout():
	timer.stop()
	_end_turn()

func _end_turn()-> void:
	_units[turn_index].is_active = false
	_icons[turn_index].is_active = false
	turn_index = (turn_index + 1) % _units.size()
	emit_signal("turn_changed")
	if turn_index == 0:
		_reinitialize_icon()
		_reinitialize()
		print("new_cycle")
	set_turn()
