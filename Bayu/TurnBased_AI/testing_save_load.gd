class_name TestingSaveLoad
extends Node2D

const gamedata = "res://gamedata.json"
@onready var card = $Sprite2D
@export var unit_id = 1

var card_name: String
var description : int
var card_ability : String
var card_type : String

var data = {
	"id_unit" : 1,
	"nama" : "Soerjo",
	"move_range" : 3,
	"attack_range" : 5,
	"armor" : 0,
	"health" : 12,
	"agility" : 3,
	"unit_role" : "ally",
	"damage" : 4,
	"ammo" : 3,
	"skin" : image_to_buffer(),
	"icon" : image_to_buffer2(),
	"inactive_icon" : image_to_buffer3(),
	"id_cards" : 1
}

var data_json = {
	"id_unit" : 1,
	"nama" : "Soerjo",
	"move_range" : 3,
	"attack_range" : 5,
	"armor" : 0,
	"health" : 12,
	"agility" : 3,
	"unit_role" : "ally",
	"damage" : 4,
	"ammo" : 3,
	"skin" : "res://Sprites/Suryo.png",
	"icon" : "res://Sprites/Icon/active_icon_soerjo-export-export.png",
	"inactive_icon" : "res://Sprites/Icon/inactive_icon_soerjo-export-export.png",
	"id_cards" : 1
}

func image_to_buffer():
	var image = preload("res://Sprites/Suryo.png")
	var pba = image.get_image().save_png_to_buffer()
	return pba

func image_to_buffer2():
	var image = preload("res://Sprites/Icon/active_icon_soerjo-export-export.png")
	var pba = image.get_image().save_png_to_buffer()
	return pba

func image_to_buffer3():
	var image = preload("res://Sprites/Icon/inactive_icon_soerjo-export-export.png")
	var pba = image.get_image().save_png_to_buffer()
	return pba
##Saving using JSON
func save_JSON(content) -> void:
	var file = FileAccess.open("res://savegame.json", FileAccess.WRITE)
	var json_stringfy = JSON.stringify(content)
	file.store_line(json_stringfy)

func save_SQLite(content) -> void:
	var database = SQLite.new()
	database.path = "res://save.db"
	database.open_db()
	
	var success = database.insert_row("testing", content)

func saving_comparrison(sqlite, json) -> void:
	var time_before = Time.get_ticks_msec()
	save_JSON(json)
	var time_after = Time.get_ticks_msec()
	print("waktu penyimpanan dengan JSON: ", time_after - time_before, " milidetik")
	var time_before_SQLite = Time.get_ticks_msec()
	save_SQLite(sqlite)
	var time_after_SQLite = Time.get_ticks_msec()
	print("waktu penyimpanan dengan SQLite ",time_after_SQLite - time_before_SQLite, "milidetik")
	#print("wakltu penyimpanan dgn SQLite: ", time_after_SQLite - time_before_SQLite, " milidetik")

func load_card_data(json_path, unit_id) -> Array:
	var file = FileAccess.open(json_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	var data = json
	var units = data["units"]
	var cards = data["cards"]
	
	#Find all card IDS 
	var unit_data = null
	for unit in data["units"]:
		if unit["id_unit"] == unit_id:
			unit_data = unit
			break
	
	if unit_data:
		var result = []
		for card_id in unit_data["id_cards"]:
			for card in cards:
				if card["id_card"] == card_id:
					result.append(card)
		return result
	return []
	# write the logics to get the card based on unit id here #
	#return array_data
	
func _ready():
	saving_comparrison(data, data_json)
