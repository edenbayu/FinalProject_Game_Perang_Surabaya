@tool
extends Control
#READ JSON FILE
@export_category("PATH TO JSON DIALOGUE")
@export var json_path = "json path here"
@export_category("PORTRAITS")
@export var character_portraits : Array[Texture2D]
#ONREADY
@onready var text_box : RichTextLabel = $Control/MarginContainer/DialogueBox/TextBox
@onready var name_box : RichTextLabel = $Control/MarginContainer/DialogueBox/NameBox/NameTextBox
@onready var portrait : TextureRect = $Control/Potrait
@onready var animation_player : AnimationPlayer = $AnimationPlayer
#VARS
var text_speed :float
var dialogue = []   #this is where we will store the data of our json
var index : int = 0 #this is the current line of dialogue in our json (starting from 0 'til the last)
var id : int    #ID of the character speaking, we use their numbers to match the portraits ARRAY
var current_color : String  #Color of the text
#SIGNAL
signal write_dialogue
 
func _ready():
	text_box.visible_characters = 0
	#Use this function whenever you want your d ialogue to start.
	start_dialogue(json_path)
 
func _process(delta):
	text_box.visible_ratio += set_progress_ratio()

func _input(event):
	#We advance the dialogue with left click or a key
	#You will need to add "interact" to your input map in project settings
	if event.is_action_pressed("klik_mouse_kiri"):
		advance_dialogue()

func set_progress_ratio() -> float:
	var text_length = text_box.text.length()
	if text_length > 0:
		return text_speed / text_length
	else:
		return 0.0
 
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
		print("Ini isi array dialogue", dialogue)
		print("jumlah dialog ", dialogue.size())
		#We access the data of our json, and add it to our text box and name box
		if dialogue[index]['Keterangan'] == "Dramatis":
			text_speed = 0.05
		elif dialogue[index]['Keterangan'] == "Normal":
			text_speed = 1.0
		text_box.text = dialogue[index]['text']
		name_box.text = dialogue[index]['name']
		id = dialogue[index]['id']
		print(id)
		check_for_color()
		check_for_potrait_baru()
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
				id = dialogue[index]['id']
				current_color = dialogue[index]['Color']
				check_for_potrait_baru()
				check_for_color()
			#If we are at the last line of dialogue, the scene deletes itself and we end.
			else : 
				queue_free()
 
func check_for_potrait_baru():
	match name_box.text:
		"Soerjo": portrait.texture = character_portraits[0]
		"Tentara Jepang": portrait.texture = character_portraits[1]

#WE CHECK THE ID GIVEN IN THE JSON, AND CHANGE THE PORTRAIT BASED ON THE INT NUMBER GIVEN
func check_for_portrait():
	match id:
		0: portrait.texture = null  #I ALWAYS MAKE 0 NULL, JUST IN CASE THERE ARE NO PORTRAITS DISPLAYED
		1: portrait.texture = character_portraits[0]
		2: portrait.texture = character_portraits[1]
		3: portrait.texture = character_portraits[2]
		4: portrait.texture = character_portraits[3]
		5: portrait.texture = character_portraits[4]
 
#WE CHECK THE COLOR GIVEN IN OUR JSON, AND CHANGE THE TEXT BASED ON THE STRING PROVIDED
func check_for_color():
	match current_color:
		'white':
			text_box.add_theme_color_override("default_color", Color.WHITE)
		'red':
			text_box.add_theme_color_override("default_color", Color.RED)
		'blue':
			text_box.add_theme_color_override("default_color", Color.BLUE)
 
#WE START THE ANIMATION THAT WILL GIVE OUR TEXT A TYPING EFFECT
func _on_write_dialogue():
	animation_player.play("WriteDialogue")
 
#YOU CAN ADD AN ARROW THAT INDICATES YOUR DIALOGUE IS DONE TYPING HERE
#I DON'T HAVE ONE FOR THE EXAMPLE SO I WILL LEAVE IT BLANK
func _on_animation_player_animation_finished(anim_name):
	#Example:
	#end_arrow_texture.visible = true
	pass
