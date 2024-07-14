class_name Settings
extends Control
@export var main_menu_music: AudioStreamPlayer2D
var master = AudioServer.get_bus_index("Master")
var sfx = AudioServer.get_bus_index("SFX")
var music = AudioServer.get_bus_index("Music")

func _change_master_volume(value):
	AudioServer.set_bus_volume_db(master,value)
	if value == -30:
		AudioServer.set_bus_mute(master,true)
	else:
		AudioServer.set_bus_mute(master,false)

func _ready():
	#main_menu_music.volume_db = -50
	main_menu_music.stream.loop = true
	main_menu_music.play()

func _process(_delta):
	pass

func _change_sfx_volume(value):
	AudioServer.set_bus_volume_db(sfx,value)
	if value == -30:
		AudioServer.set_bus_mute(sfx,true)
	else:
		AudioServer.set_bus_mute(sfx,false)

func _change_music_volume(value):
	AudioServer.set_bus_volume_db(music,value)
	if value == -30:
		AudioServer.set_bus_mute(music,true)
	else:
		AudioServer.set_bus_mute(music,false)


func _on_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
