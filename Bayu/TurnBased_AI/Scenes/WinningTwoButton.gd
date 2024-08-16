class_name WinningTwoButton
extends Button

func go_to_next_level() -> void:
	LevelState.set_level_status(1)
	LevelState.set_current_level(3)
	get_tree().change_scene_to_file("res://Scenes/level_menu.tscn")
	print("clciked!")
