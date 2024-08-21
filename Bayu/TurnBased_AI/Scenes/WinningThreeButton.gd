class_name WinningThreeButton
extends Button

func go_to_next_level() -> void:
	LevelState.set_level_status(1)
	LevelState.set_current_level(3)
	get_tree().change_scene_to_file("res://DialogSistem/dialog_sistem_3.2tscn.tscn")
