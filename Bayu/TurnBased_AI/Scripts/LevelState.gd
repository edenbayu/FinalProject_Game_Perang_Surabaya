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

func save_data(new_id_level: int, new_level_status: int) -> void:
	var file = FileAccess.open(savedata, FileAccess.READ)
	var data = file.get_as_text()
	var json_data = JSON.parse_string(data)
	file.close()
	
	for item in json_data:
		if item.id == current_saving_id:
			item.id_level = new_id_level
			item.last_saved_time = get_new_date()
			item.level_status = new_level_status
			break
	file = FileAccess.open(savedata, FileAccess.WRITE)
	file.store_line(JSON.stringify(json_data))
	file.close
	print("data berhasil disimpan! na")

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
	return {}

func get_new_date() -> String:
	var time = Time.get_datetime_dict_from_system()
	print(time)
	return str("%04d-%02d-%02d" % [time.year, time.month, time.day]) + " " + str("%02d:%02d:%02d" % [time.hour, time.minute, time.second])
