extends Control

@onready var text : RichTextLabel = $MarginContainer/Dialoguebox/AnimatedSprite2D/RichTextLabel
signal enter_gameplay
var array_text = [
	"Kita sudah berhasil masuk,
Ayo serbuuu!!",
	"Jangan biarkan bendera Belanda tetap berkibar di tanah air",
	"Kita unggul dalam jumlah, jangan sia-siakan peluang kemenangan!"
]
var index : int

# Called when the node enters the scene tree for the first time.
func _ready():
	index = 0
	$MarginContainer/Dialoguebox/AnimatedSprite2D.play("default")
	text.visible_ratio = 0
	text.text = array_text[index]

func mini_dialog() -> void:
	index += 1
	if index < array_text.size():
		if text.visible_ratio >= 1:
			text.visible_ratio = 0
			text.text = array_text[index]
	elif index >= array_text.size():
		enter_gameplay.emit()
		queue_free()

func _input(event):
	if Input.is_action_pressed("klik_mouse_kiri"):
		mini_dialog()
	#enter_game()

func _process(delta):
	text.visible_ratio += 0.01

func enter_game() -> void:
	if Input.is_action_pressed("klik_mouse_kiri") and index >= 2:
		enter_gameplay.emit()
		queue_free()
