class_name Dialog2
extends Control
#READ JSON FILE
@export_category("PATH TO JSON DIALOGUE")
@export var json_path = "res://DialogSistem/DialogueSistem2.json"
@export_category("PORTRAITS")
@export var character_portraits : Array[Texture2D]
@export var scene_background : Array[Texture2D]
#ONREADY
@onready var text_box : RichTextLabel = $Control/MarginContainer/DialogueBox/Textbox
@onready var name_box : RichTextLabel = $Control/MarginContainer/DialogueBox/Nametextbox
@onready var portrait_kiri : TextureRect = $Control/Char1
@onready var portrait_kanan : TextureRect = $Control/Char2
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var name_box_container : TextureRect = $Control/MarginContainer/DialogueBox/Namebox
@onready var background : TextureRect = $Background
@onready var trans_text : RichTextLabel = $Transition/TransitionText
@onready var transition : TextureRect = $Transition
#VARS
var sound = preload("res://Scenes/SoundManager.tscn")
var text_speed :float
var dialogue = []   #this is where we will store the data of our json
var index : int = 0 #this is the current line of dialogue in our json (starting from 0 'til the last)
var id : int    #ID of the character speaking, we use their numbers to match the portraits ARRAY
var current_color : String  #Color of the text
var posisi_nama : String #Menentukan posisi name box
var nama_portrait_kanan : String
var nama_portrait_kiri : String
var current_background : int

#Animation
@export var is_faded_black : bool = true
#SIGNAL
signal write_dialogue
 
func _ready():
	is_faded_black = true
	text_box.visible_characters = 0
	trans_text.visible_characters = 0
	#Use this function whenever you want your d ialogue to start.
	start_dialogue(json_path)
	sound = sound.instantiate()
	add_child(sound)
	sound.sound_level1()
 
func _process(delta):
	#print(is_faded_black)
	text_box.visible_ratio += set_progress_ratio()
	#if is_faded_black:
		#trans_text.visible_ratio += show_transition_text()
	#if trans_text.visible_ratio >= 1:
		#is_faded_black = false

func _input(event):
	#We advance the dialogue with left click or a key
	#You will need to add "interact" to your input map in project settings
	if event.is_action_pressed("klik_mouse_kiri"):
		_transition()
		if is_faded_black:
			advance_dialogue()

func set_progress_ratio() -> float:
	var text_length = text_box.text.length()
	if text_length > 0:
		return text_speed / text_length
	else:
		return 0.0

func show_transition_text() -> float:
	var text_length = trans_text.text.length()
	if text_length > 0:
		return 0.05 / text_length
	else:
		return 0.0
 
func fade_out() -> void:
	animation_player.play("fade_out")
	advance_dialogue()

#LOAD THE JSON FILE INTO A READABLE FORMAT FOR GODOT
func load_dialogue(path : String):
	var json_as_text = FileAccess.get_file_as_string(path)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict
 
#STORE THE JSON FILES DATA INTO OUR 'DIALOGUE' ARRAY
func start_dialogue(path : String):
	#emit_signal("write_dialogue")
	index = 0
	if FileAccess.file_exists(path):
		print("File exist!")
		dialogue = load_dialogue(path)
		#We access the data of our json, and add it to our text box and name box
		if dialogue[index]['Keterangan'] == "Dramatis":
			text_speed = 0.05
		elif dialogue[index]['Keterangan'] == "Normal":
			text_speed = 10.0
		current_color = dialogue[index]['Color']
		text_box.text = dialogue[index]['text']
		name_box.text = dialogue[index]['name']
		nama_portrait_kiri = dialogue[index]['tokoh'][0]
		nama_portrait_kanan = dialogue[index]['tokoh'][1]
		posisi_nama = dialogue[index]['PosNama']
		id = dialogue[index]['id']
		current_background = dialogue[index]['BG']
		
		_setup_background()
		_check_posisi_nama()
		check_for_color()
		check_for_potrait_kiri()
		check_for_potrait_kanan()
	else : print("File isn't exist!")
 
func advance_dialogue():
	#If our text is entirely visible (meaning is done writing) we can move on to the next line
	match text_box.visible_ratio == 1:
		true:
			#emit_signal("write_dialogue")
			index += 1
			#We check if we still have lines of dialogue left, if we do, we continue
			if index < dialogue.size():
				if dialogue[index]['Keterangan'] == "Dramatis":
					text_speed = 0.05
				elif dialogue[index]['Keterangan'] == "Normal":
					text_speed = 1.0
				text_box.text = dialogue[index]['text']
				text_box.visible_characters = 0
				name_box.text = dialogue[index]['name']
				nama_portrait_kiri = dialogue[index]['tokoh'][0]
				nama_portrait_kanan = dialogue[index]['tokoh'][1]
				id = dialogue[index]['id']
				current_color = dialogue[index]['Color']
				posisi_nama = dialogue[index]['PosNama']
				current_background = dialogue[index]['BG']
				_setup_background()
				_check_posisi_nama()
				check_for_potrait_kiri()
				check_for_potrait_kanan()
				check_for_color()
			#If we are at the last line of dialogue, the scene deletes itself and we end.
			#else : 
				#queue_free()
 
func check_for_potrait_kiri():
	match nama_portrait_kiri:
		"SOERJO": portrait_kiri.texture = character_portraits[0]
		"SOEHARTINI": portrait_kiri.texture = character_portraits[1]
		"TKR 1" : portrait_kiri.texture = character_portraits [2]
		"TKR 2" : portrait_kiri.texture = character_portraits [3]
		"" : portrait_kiri.texture = character_portraits [4]
		"TKR 3" : portrait_kiri.texture = character_portraits [5]
		"MOESTOPO" : portrait_kiri.texture = character_portraits [6]
		"MALLABY" : portrait_kiri.texture = character_portraits [7]
		"WARGA 1" : portrait_kiri.texture = character_portraits [8]
		"WARGA 2" : portrait_kiri.texture = character_portraits [9]
func check_for_potrait_kanan():
	match nama_portrait_kanan:
		"SOERJO": portrait_kanan.texture = character_portraits[0]
		"SOEHARTINI": portrait_kanan.texture = character_portraits[1]
		"TKR 1" : portrait_kanan.texture = character_portraits [2]
		"TKR 2" : portrait_kanan.texture = character_portraits [3]
		"" : portrait_kanan.texture = character_portraits [4]
		"TKR 3" : portrait_kanan.texture = character_portraits [5]
		"MOESTOPO" : portrait_kanan.texture = character_portraits [6]
		"MALLABY" : portrait_kanan.texture = character_portraits [7]
		"WARGA 1" : portrait_kanan.texture = character_portraits [8]
		"WARGA 2" : portrait_kanan.texture = character_portraits [9]

#WE CHECK THE COLOR GIVEN IN OUR JSON, AND CHANGE THE TEXT BASED ON THE STRING PROVIDED
func check_for_color():
	match current_color:
		'white':
			text_box.add_theme_color_override("default_color", Color.WHITE)
		'red':
			text_box.add_theme_color_override("default_color", Color.RED)
		'blue':
			text_box.add_theme_color_override("default_color", Color.BLUE)
		'oren':
			text_box.add_theme_color_override("default_color", Color.ORANGE)
		_:
			text_box.add_theme_color_override("default_color", Color.CHARTREUSE)

#WE START THE ANIMATION THAT WILL GIVE OUR TEXT A TYPING EFFECT
func _on_write_dialogue():
	animation_player.play("WriteDialogue")
 
func _check_posisi_nama():
	match posisi_nama:
		'kiri':
			portrait_kanan.modulate = Color(0.5,0.5,0.5)
			portrait_kiri.modulate = Color(1,1,1)
			#name_box_container.scale.x = -1
			#name_box.position.x = 0
			pass
		'kanan':
			portrait_kanan.modulate = Color(1,1,1)
			portrait_kiri.modulate = Color(0.5,0.5,0.5)
			pass
			#name_box_container.scale.x = 1
			#name_box.position.x = 960
#YOU CAN ADD AN ARROW THAT INDICATES YOUR DIALOGUE IS DONE TYPING HERE
#I DON'T HAVE ONE FOR THE EXAMPLE SO I WILL LEAVE IT BLANK
func _setup_background():
	match current_background:
		0 :
			background.texture = scene_background[0]
		1 :
			background.texture = scene_background[1]
		2: 	
			background.texture = scene_background[2]
		3: 	
			background.texture = scene_background[3]

func _transition():
	pass
	#match id:
		#10:
			#is_faded_black = false
			#animation_player.play("transition")
			#show_transition_text()
#func _transition1():
	#match id:
		#33:
			#is_faded_black = false
			#animation_player.play("transition")
			#show_transition_text()
