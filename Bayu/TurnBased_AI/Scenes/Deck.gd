class_name Deck
extends Control

@onready var timer = $Timer
@onready var hands = $Hands
@onready var gameboard :GameBoard = $"../../GameBoard"

# Called when the node enters the scene tree for the first time.
func _ready():
	_match_card_functionalities()
	for card in $Hands.get_children():
		var kartu := card as Card
		if not kartu:
			continue
		kartu.card_chose.connect(on_card_chosen)

	timer.timeout.connect(_on_timer_timeout)
	

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

func _match_card_functionalities():
	for card in hands.get_children():
		var kartu = card as Card
		if not kartu:
			continue
		match kartu.card_type:
			'Walk':
				kartu.mouse_entered.connect(gameboard.testing_card)
				kartu.card_chose.connect(gameboard.walk)
				kartu.mouse_exited.connect(gameboard.delete_walk_tiles)
			'Innate':
				kartu.mouse_entered.connect(gameboard.innate_reload)
				kartu.card_chose.connect(gameboard.reload)
			'Attack':
				kartu.mouse_entered.connect(gameboard.show_attack)
				kartu.card_chose.connect(gameboard.attack)
