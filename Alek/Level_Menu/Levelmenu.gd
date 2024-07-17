extends Node

@onready var level1 = $Level1
@onready var level2 = $Level2
@onready var level3 = $Level3

var current_level := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	current_level = 1
	level2.visible = false
	level3.visible = false
	
#dstnya smp levl terakir visiblenya false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_level < 1:
		current_level = 1
	elif current_level > 3:
		current_level = 3

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

func _on_button_pressed():
	current_level += 1
	match_level()

func _on_button_2_pressed():
	current_level -= 1
	match_level()

func _on_select_1_pressed():
	current_level = 1
	match_level()

func _on_select_2_pressed():
	current_level = 2
	match_level()
	
func _on_select_3_pressed():
	current_level = 3
	match_level()
