class_name Deck
extends Control

@onready var status_ui = $"../StatusUI"
@onready var gameboard :GameBoard = $"../../../../../GameBoard"
signal card_unseen

var database = SQLite

# Called when the node enters the scene tree for the first time.
func _ready():
	match_card_functionalities()
	for card in self.get_children():
		var kartu := card as Card
		if not kartu:
			continue
		kartu.card_chose.connect(on_card_chosen)

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
	tween.tween_property(self, "position", Vector2(self.position.x, 480), 1)
	card_unseen.emit()

func show_card():
	var tween : Tween
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "position", Vector2(self.position.x, 0), 1)

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
		self.add_child(instance)
	match_card_functionalities()

func clear_hands():
	for card in self.get_children():
		card.queue_free()

func match_card_functionalities():
	for card in self.get_children():
		var kartu = card as Card
		if not kartu:
			continue
		if not kartu.disabled:
			match kartu.card_type:
				'Walk':
					kartu.mouse_entered.connect(gameboard.testing_card)
					kartu.on_card_selected.connect(gameboard.on_card_clicked)
				'Reload':
					kartu.mouse_entered.connect(gameboard.innate_reload)
					kartu.on_card_selected.connect(gameboard.on_card_clicked)
				'Attack':
					kartu.mouse_entered.connect(gameboard.show_attack)
					kartu.on_card_selected.connect(gameboard.on_card_clicked)


func inactive_innate_ability() ->void:
	LevelManager.active_unit.innate_card = false

func inactive_modular_ability() ->void:
	LevelManager.active_unit.modular_card = false

func disable_innate_card() -> void:
	for card in self.get_children():
		if card.card_attribute == "innate":
			card.disabled = true
			card._back_texture.material["shader_parameter/y_rot"] = 0
			card._back_texture.use_parent_material = true
			card._back_texture.modulate = Color(0.50, 0.5, 0.5)

func disable_modular_card() -> void:
	for card in self.get_children():
		if card.card_attribute == "modular":
			card.disabled = true
			card._back_texture.material["shader_parameter/y_rot"] = 0
			card._back_texture.use_parent_material = true
			card._back_texture.modulate = Color(0.50, 0.5, 0.5)

func reset_card() -> void:
	for card in self.get_children():
		card.disabled = false
		card._back_texture.material["shader_parameter/y_rot"] = 90
		card._back_texture.use_parent_material = false
		card._back_texture.modulate = Color (1.0, 1.0, 1.0)
