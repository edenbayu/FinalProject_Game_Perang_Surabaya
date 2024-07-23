class_name EnemyController
extends Node2D

var curr_health: float:
	set(value):
		curr_health = clamp(value, 0, 100)
var is_within_range := false
var is_empty_ammo := false
var innate_done := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	curr_health = LevelManager.active_unit.curr_health
	is_within_range = LevelManager.active_unit.is_within_range
	is_empty_ammo = LevelManager.active_unit.is_empty_ammo
	innate_done = LevelManager.active_unit.innate_done
