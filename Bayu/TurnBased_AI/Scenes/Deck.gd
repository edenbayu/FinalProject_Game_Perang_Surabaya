class_name Deck
extends Control

@onready var timer = $Timer
@onready var hands = $Hands
@onready var status_ui = $"../UI/StatusUI"
@onready var gameboard :GameBoard = $"../../GameBoard"

var database = SQLite

# Called when the node enters the scene tree for the first time.
func _ready():
	match_card_functionalities()
	for card in $Hands.get_children():
		var kartu := card as Card
		if not kartu:
			continue
		kartu.card_chose.connect(on_card_chosen)

	timer.timeout.connect(_on_timer_timeout)

func initialize_card() -> void:
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_card_chosen():
	var tween : Tween
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Hands, "position", Vector2($Hands.position.x, 200), 1)
	timer_setart()

func timer_setart():
	timer.start(1.5)

func _on_timer_timeout():
	var tween : Tween
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Hands, "position", Vector2($Hands.position.x, -280), 1)

#Fungsi untuk menginstansiasi kartu baru sesuai dengan unit
func spawn_new_card(result):
	for i  in result:
		var scene = preload("res://Scenes/Cards.tscn")
		var instance = scene.instantiate()
		
		#Konfigurasi attrribut kartu sesuai dengan hasil query
		var card_image = Image.new()
		card_image.load_png_from_buffer(i.texture)
		var texture = ImageTexture.create_from_image(card_image)
		instance.card_texture = texture
		var back_card_image = Image.new()
		back_card_image.load_png_from_buffer(i.back_texture)
		var back_texture = ImageTexture.create_from_image(back_card_image)
		instance.back_texture = back_texture
		instance.card_description = i.description
		instance.card_type = i.card_ability
		instance.card_attribute = i.card_type
		print(instance.card_attribute)
		hands.add_child(instance)

func match_card_functionalities():
	for card in hands.get_children():
		var kartu = card as Card
		if not kartu:
			continue
		if not kartu.disabled:
			match kartu.card_type:
				'Walk':
					kartu.mouse_entered.connect(gameboard.testing_card)
					kartu.card_chose.connect(inactive_innate_ability)
					kartu.card_chose.connect(disable_innate_card)
					kartu.card_chose.connect(on_card_chosen)
					#kartu.pressed.connect(spawn_new_card)
					#kartu.mouse_exited.connect(gameboard.delete_walk_tiles)
				'Innate':
					kartu.mouse_entered.connect(gameboard.innate_reload)
					kartu.card_chose.connect(gameboard.reload)
				'Attack':
					kartu.mouse_entered.connect(gameboard.show_attack)
					kartu.card_chose.connect(gameboard.attack)
					kartu.card_chose.connect(on_card_chosen)
					kartu.card_chose.connect(disable_modular_card)

		match kartu.card_attribute:
			'innate':
				kartu.card_chose.connect(status_ui.burn_innate_card)
			'modular':
				kartu.card_chose.connect(status_ui.burn_modular_card)

func inactive_innate_ability() ->void:
	LevelManager.active_unit.innate_card = false

func disable_innate_card() -> void:
	for card in hands.get_children():
		if card.card_attribute == "innate":
			card.disabled = true
			card._back_texture.material["shader_parameter/y_rot"] = 0
			card._back_texture.use_parent_material = true
			card._back_texture.modulate = Color(0.50, 0.5, 0.5)

func disable_modular_card() -> void:
	for card in hands.get_children():
		if card.card_attribute == "modular":
			card.disabled = true
			card._back_texture.material["shader_parameter/y_rot"] = 0
			card._back_texture.use_parent_material = true
			card._back_texture.modulate = Color(0.50, 0.5, 0.5)
