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
	var file = FileAccess.open(save_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	file.close()
	
	var latest_save_data = null
	var latest_time = ""
	for i in json:
		if latest_save_data == null or Time.get_unix_time_from_datetime_string(i.last_saved_time) > Time.get_unix_time_from_datetime_string(latest_time):
			latest_save_data = i
			latest_time = i.last_saved_time
	if latest_save_data != null:
		match_load_data(latest_save_data)
		LevelState.set_current_saving_id(latest_save_data.id)
	else:
		print("No save data found!")

func _on_load_game_pressed():
	var file = FileAccess.open(save_path, FileAccess.READ)
	var data = file.get_as_text()
	var json = JSON.parse_string(data)
	file.close()
	
	var i = 1
	var load_button = $LoadGame/MoetGame/VBoxContainer.get_children()
	for button in load_button:
		button.get_child(0).text = "PENYIMPANAN " + str(i)
		button.get_child(1).text = json[(i-1)].last_saved_time
		button.get_child(2).text = "BAB" + str(json[(i - 1)].id_level) + " " + "BAGIAN " + str(json[(i - 1)].level_status)
		i += 1
	sound_button.click_sound()
	load.visible = true

func _on_setting_game_pressed():
	press_button.play()
	setting.visible = true

func _on_credit_pressed():
	sound_button.click_sound()
	
func _on_exit_pressed():
	get_tree().quit()
	
func get_new_date() -> String:
	var time = Time.get_datetime_dict_from_system()
	print(time)
	return str("%04d-%02d-%02d" % [time.year, time.month, time.day]) + " " + str("%02d:%02d:%02d" % [time.hour, time.minute, time.second])

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
	var data = LevelState.load_data(1)
	LevelState.set_current_saving_id(1)
	match_load_data(data)

func _on_load1_game_mouse_pressed():
	sound_button.click_sound()
	var data = LevelState.load_data(2)
	LevelState.set_current_saving_id(2)
	match_load_data(data)

func _on_load2_game_mouse_pressed():
	sound_button.click_sound()
	var data = LevelState.load_data(3)
	LevelState.set_current_saving_id(3)
	match_load_data(data)

func _on_load3_game_mouse_pressed():
	sound_button.click_sound()
	var data = LevelState.load_data(4)
	LevelState.set_current_saving_id(4)
	match_load_data(data)

func match_load_data(data: Dictionary) -> void:
	match str(data.id_level):
		"1":
			if data.level_status == 1:
				LoadManager.load_scene("res://DialogSistem/DialogueSistem.tscn")
			elif data.level_status == 2:
				LoadManager.load_scene("res://Scenes/level.tscn")
		"2":
			if data.level_status == 1:
				LoadManager.load_scene("res://DialogSistem/dialogue_sistem_2.tscn")
			elif data.level_status == 2:
				LoadManager.load_scene("res://Scenes/level_2.tscn")
		"3":
			if data.level_status == 1:
				LoadManager.load_scene("res://DialogSistem/dialog_sistem_3.tscn")
			elif data.level_status == 2:
				LoadManager.load_scene("res://Scenes/level3.tscn")
			elif data.level_status == 3:
				LoadManager.load_scene("res://DialogSistem/dialog_sistem_3.2tscn.tscn")
			elif data.level_status == 4:
				LoadManager.load_scene("res://Scenes/level_3_2.tscn")
			elif data.level_status == 5:
				LoadManager.load_scene("res://Scenes/FinalLevel.tscn")
