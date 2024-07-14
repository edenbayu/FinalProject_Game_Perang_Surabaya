extends Node

var save_data : SQLite
var created_new_save_data := false
var level = null
@onready var continue_button = $"MainMenu/VBoxContainer/ContinueGame"
@onready var load_button = $"MainMenu/VBoxContainer/LoadGame"
@onready var main_menu_music = $main_menu_back_music
@onready var setting = $Pengaturan
@onready var menu = $MainMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	menu.visible = true
	setting.visible = false
	_check_new_date()
	continue_button.visible = true
	load_button.visible = true
	created_new_save_data = false
	_open_database()
	_get_savings_data()

#func backsound_low_to_high(delta):
	#main_menu_music.volume_db += linear_to_db(8.0) * delta
	#if main_menu_music.volume_db >= -10:
		#main_menu_music.volume_db = -10
	#print(main_menu_music.volume_db)
		
func _open_database():
	save_data = SQLite.new()
	save_data.path = "res://save.db"
	save_data.open_db()

func _get_savings_data():
	save_data.query("Select level_name from level")
	var results = save_data.query_result
	for result in results:
		if result.level_name != null:
			continue_button.visible = true
			load_button.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#backsound_low_to_high(delta)

func _on_new_game_pressed():
	save_data.query("Select id, level_name, last_saved_time from level")
	var result_1 = save_data.query_result
	for result in result_1:
		if result['level_name'] == null and !created_new_save_data:
			save_data.update_rows('Level', 'id = '+ str(result['id']), {'level_name' = 'Chapter One'})
			save_data.update_rows('Level', 'id = '+ str(result['id']), {'last_saved_time' = _check_new_date()})
			created_new_save_data = true
			get_tree().change_scene_to_file("res://Prolog.tscn")
		elif created_new_save_data:
			return
		else:
			save_data.update_rows('Level', 'id = 1', {'level_name' = 'Chapter One'})
			save_data.update_rows('Level', 'id = 1', {'last_saved_time' = _check_new_date()})
			get_tree().change_scene_to_file.bind("res://Prolog.tscn").call_deferred() ##Bug change scene di godot 4.2
	created_new_save_data = false

func _on_continue_game_pressed():
	save_data.query("SELECT id, level_name, last_saved_time
FROM Level
ORDER BY substr(last_saved_time, 7, 4) || '-' || substr(last_saved_time, 4, 2) || '-' || substr(last_saved_time, 1, 2) || ' ' || substr(last_saved_time, 12, 8) DESC
LIMIT 1;")
	var result = save_data.query_result
	#level = save_data.query_result['level_name'][0]
	for i in result:
		level = i.level_name
	_match_loaded_save(level)
	

func _on_load_game_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_setting_game_pressed():
	setting.visible = true
	#get_tree().change_scene_to_file("res://node_2d.tscn")
	
func _on_exit_pressed():
	get_tree().quit()
	
func _check_new_date() -> String:
	var time = Time.get_datetime_dict_from_system()
	return str("%02d-%02d-%04d" % [time.day, time.month, time.year]) + " " + str("%02d:%02d:%02d" % [time.hour, time.minute, time.second])

func _match_loaded_save(chapter: String):
	match(chapter):
		"Chapter One" : get_tree().change_scene_to_file("res://Prolog.tscn")
		"Chapter Two" : pass #get scene ke Chapter kedua
		"Chapter Three" : get_tree().change_scene_to_file("res://chapter_three.tscn")

func on_back_button_pressed() -> void:
	menu.visible = true
	setting.visible = false
