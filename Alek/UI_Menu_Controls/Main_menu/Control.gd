extends Control
@export var sound: AudioStreamPlayer2D
@export var sound2: AudioStreamPlayer2D
@export var sound3: AudioStreamPlayer2D
var master = AudioServer.get_bus_index("Master")
var sfx = AudioServer.get_bus_index("SFX")
var music = AudioServer.get_bus_index("Music")
func _on_h_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master,value)
	if value == -30:
		AudioServer.set_bus_mute(master,true)
	else:
		AudioServer.set_bus_mute(master,false)
func _ready():
	sound.play()
	sound2.play()
	print("ini ready")

func _process(_delta):
	pass
func _ngubah_volume_sfx(value):
	AudioServer.set_bus_volume_db(sfx,value)
	if value == -30:
		AudioServer.set_bus_mute(sfx,true)
	else:
		AudioServer.set_bus_mute(sfx,false)

func _on_h_slider_3_value_changed(value):
	AudioServer.set_bus_volume_db(music,value)
	if value == -30:
		AudioServer.set_bus_mute(music,true)
	else:
		AudioServer.set_bus_mute(music,false)


func _on_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
