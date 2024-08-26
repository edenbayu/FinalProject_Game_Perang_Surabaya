extends Node

const gamedata = "res://savings/gamedata.json"

func load_unit_data(unit_id) -> Dictionary:
	var file = FileAccess.open(gamedata, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	var data = json
	var units = data["units"]
	
	#Find the unit by its ID
	for unit in units:
		if unit["id_unit"] == unit_id:
			return unit
	return {}
	
func load_card_data(unit_id) -> Array:
	var file = FileAccess.open(gamedata, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.parse_string(content)
	var data = json
	var units = data["units"]
	var cards = data["cards"]
	
	#Find all card IDs
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
	

