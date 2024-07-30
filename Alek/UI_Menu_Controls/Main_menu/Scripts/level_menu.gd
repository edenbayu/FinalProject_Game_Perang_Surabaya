class_name LevelMenu
extends Control

@onready var level1 = $Level1
@onready var level2 = $Level2
@onready var level3 = $Level3
@export var level_menu_kronologi : Array[Texture2D]

var sound_button = preload("res://Scenes/SoundManager.tscn")
var current_level := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	match_state_level()
	current_level = 1
	level2.visible = false
	level3.visible = false
	sound_button = sound_button.instantiate()
	add_child(sound_button)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_level < 1:
		current_level = 1
	elif current_level > 3:
		current_level = 3

func match_state_level() -> void:
	match LevelState.current_level:
		1:
			$Level1/Kronologi.texture = level_menu_kronologi[0]
			$Level2/Kronologi.texture = level_menu_kronologi[1]
			$Level3/Kronologi.texture = level_menu_kronologi[1]
			$Level2/Kronologi/Label.visible = false
			$Level2/Kronologi/Label2.visible = false
			$Level2/Button.visible = false
			$Level3/Kronologi/Label.visible = false
			$Level3/Kronologi/Label2.visible = false
			$Level3/Button.visible = false
		2:
			$Level1/Kronologi.texture = level_menu_kronologi[0]
			$Level2/Kronologi.texture = level_menu_kronologi[0]
			$Level3/Kronologi.texture = level_menu_kronologi[1]
			$Level3/Kronologi/Label.visible = false
			$Level3/Kronologi/Label2.visible = false
			$Level3/Button.visible = false
		3:
			$Level1/Kronologi.texture = level_menu_kronologi[0]
			$Level2/Kronologi.texture = level_menu_kronologi[0]
			$Level3/Kronologi.texture = level_menu_kronologi[0]

func match_level() -> void:
	match current_level:
		1: 
			level1.visible = true
			level2.visible = false
			level3.visible = false
		2: 
			level2.visible = true
			level1.visible = false
			level3.visible = false
		3:
			level3.visible  = true
			level2.visible = false
			level1.visible = false

func _hover_button_level_1():
	sound_button.click_sound()
	LoadManager.load_scene("res://DialogSistem/DialogueSistem.tscn")
	#get_tree().change_scene_to_file("res://LoadingScreen/loading_screen.tscn")

func _entered_button_level_1():
	sound_button.button_sound()
	
func _hover_button_level_2():
	sound_button.click_sound()
	LoadManager.load_scene("res://DialogSistem/dialogue_sistem_2.tscn")

func _entered_button_level_2():
	sound_button.button_sound()
	
func _hover_button_level_3():
	sound_button.click_sound()

func _entered_button_level_3():
	sound_button.button_sound()
	

func _on_select_pressed():
	current_level = 1
	match_level()
	sound_button.click_sound()

func _on_select_2_pressed():
	current_level = 2
	match_level()
	sound_button.click_sound()
	
func _on_select_3_pressed():
	current_level = 3
	match_level()
	sound_button.click_sound()

func _hover_select_1():
	sound_button.button_sound()

func _hover_select_2():
	sound_button.button_sound()

func _hover_select_3():
	sound_button.button_sound()

func _hover_back_entered():
	sound_button.button_sound()	
	
func on_back_button_pressed():
	sound_button.click_sound()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
