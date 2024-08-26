extends Control

var save_data : SQLite
var created_new_save_data := false
@onready var continue_button = $"MainMenu/VBoxContainer/ContinueGame"
@onready var load_button = $"MainMenu/VBoxContainer/LoadGame"
@onready var setting = $Pengaturan
@onready var menu = $MainMenu
@onready var button_sound = $soundbutton
@onready var press_button = $pressbutton
@onready var load = $LoadGame

const save_path = "res://savings/saving.json"
var sound_button = preload("res://Scenes/SoundManager.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	continue_button.disabled = true
	load_button.disabled = true
	menu.visible = true
	setting.visible = false
	load.visible = false
	get_new_date()
	created_new_save_data = false
	_open_database()
	_get_savings_data()

	sound_button = sound_button.instantiate()
	add_child(sound_button)

func _open_database():
	save_data = SQLite.new()
	save_data.path = "res://save.db"
	save_data.open_db()

func _get_savings_data():
	save_data.query("Select id_level from level")
	var results = save_data.query_result
	for result in results:
		if result.id_level != null:
			continue_button.disabled = false
			load_button.disabled = false
			break

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#backsound_low_to_high(delta)

func _on_new_game_pressed() -> void:
	press_button.play()
	sound_button.click_sound()
	
	var update_made = false
	var file = FileAccess.open(save_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	file.close()
	
	for item in json:
		if item.id_level == 0:
			item.id_level = 1
			item.last_saved_time = get_new_date()
			item.level_status = 1
			update_made = true
			LevelState.set_current_saving_id(item.id)
			LevelState.set_level_status(1)
			LevelState.set_current_level(1)
			get_tree().change_scene_to_file("res://Scenes/level_menu.tscn")
			break
	if not update_made:
		for item in json:
			if item.id == 1:
				item.id_level = 1
				item.last_saved_time = get_new_date()
				item.level_status = 1
				LevelState.set_current_saving_id(1)
				LevelState.set_level_status(1)
				LevelState.set_current_level(1)
				get_tree().change_scene_to_file("res://Scenes/level_menu.tscn")
				break
	file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		print("Failed to write data!")
		return
	file.store_line(JSON.stringify(json))
	file.close()

func _on_continue_game_pressed():
	save_data.query("SELECT id, id_level, level_status, last_saved_time
					FROM level
					ORDER BY last_saved_time DESC
					limit 1;")
	var result = save_data.query_result
	LevelState.set_current_saving_id(result[0].id)
	LevelState.set_current_level(result[0].id_level)
	LevelState.set_level_status(result[0].level_status)
	get_tree().change_scene_to_file("res://Scenes/level_menu.tscn")
	

func _on_load_game_pressed():
	save_data.query("SELECT id, id_level, level_status, last_saved_time from level ORDER BY id;")
	var results = save_data.query_result
	var i = 1
	#for result in results:
	var load_buttons = $LoadGame/MoetGame/VBoxContainer.get_children()
	for button in load_buttons:
		if results[(i-1)].last_saved_time == null:
			continue
		button.get_child(0).text = "PENYIMPANAN " + str(i)
		button.get_child(1).text = results[(i - 1)].last_saved_time
		button.get_child(2).text = "BAB " + str(results[(i - 1)].id_level) + " " + "BAGIAN " + str(results[(i - 1)].level_status)
		i += 1
		#get_node("Label").text = "PENYIMPANAN" + str(result)
	sound_button.click_sound()
	load.visible = true

func _on_setting_game_pressed():
	press_button.play()
	setting.visible = true
	#get_tree().change_scene_to_file("res://node_2d.tscn")

func _on_credit_pressed():
	sound_button.click_sound()
	
func _on_exit_pressed():
	get_tree().quit()
	
func get_new_date() -> String:
	var time = Time.get_datetime_dict_from_system()
	print(time)
	return str("%02d-%02d-%04d" % [time.day, time.month, time.year]) + " " + str("%02d:%02d:%02d" % [time.hour, time.minute, time.second])

func _match_loaded_save(chapter: String):
	if LevelState.current_level == 2:
		match LevelState.level_status:
			1:
				print("level 2 scene 1")
			2:
				print("level 2 scene 2")
			3:
				print("level 2 scene 3")

func on_back_button_pressed() -> void:
	menu.visible = true
	setting.visible = false
	load.visible = false
	sound_button.click_sound()

func on_load_back_button_pressed() -> void:
	menu.visible = true
	setting.visible = false
	load.visible = false
	sound_button.click_sound()

func _on_continue_game_mouse_entered():
	if not $MainMenu/VBoxContainer/ContinueGame.disabled:
		button_sound.play()

func _load_game_mouse_entered():
	sound_button.button_sound()

func _on_new_game_mouse_entered():
	sound_button.button_sound()

func _on_setting_game_mouse_entered():
	sound_button.button_sound()

func _on_credit_mouse_entered():
	button_sound.play()

func _on_exit_mouse_entered():
	button_sound.play()
	
func _on_load_game_mouse_entered():
	sound_button.button_sound()

func _on_load1_game_mouse_entered():
	sound_button.button_sound()

func _on_load2_game_mouse_entered():
	sound_button.button_sound()
	
func _on_load3_game_mouse_entered():
	sound_button.button_sound()

func _on_load_game_mouse_pressed():
	sound_button.click_sound()

func _on_load1_game_mouse_pressed():
	sound_button.click_sound()

func _on_load2_game_mouse_pressed():
	sound_button.click_sound()

func _on_load3_game_mouse_pressed():
	sound_button.click_sound()
