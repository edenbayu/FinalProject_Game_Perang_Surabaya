extends Node

const savedata = "res://savings/saving.json"

var current_saving_id : int
var current_level : int
var level_status : int
var saving_database : SQLite

func set_current_saving_id(new_saving_id: int) -> void:
	current_saving_id = new_saving_id

func set_current_level(new_current_level: int) -> void:
	current_level = new_current_level

func set_level_status(new_level_status : int) -> void:
	level_status = new_level_status

func save_game() -> void:
	if current_saving_id == null:
		return
	saving_database = SQLite.new()
	saving_database.path = "res://save.db"
	saving_database.open_db()
	
	var save = saving_database.update_rows("Level", "id = " + str(current_saving_id), {"id_level" = current_level, "level_status" = level_status})

func load_data(saving_id: int) -> Dictionary:
	var file = FileAccess.open(savedata, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	
	for data in json:
		if data.id == saving_id:
			return {
				"id": data.id,
				"id_level" : data.id_level,
				"level_status": data.level_status
			}
	print(json)
	return {}
