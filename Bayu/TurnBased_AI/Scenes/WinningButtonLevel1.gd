class_name WinningOneButton
extends Button

func go_to_next_level() -> void:
	LevelState.set_level_status(1)
	LevelState.set_current_level(2)
	LevelState.save_data(2,1)
	get_tree().change_scene_to_file("res://Scenes/level_menu.tscn")
	print("clciked!")
