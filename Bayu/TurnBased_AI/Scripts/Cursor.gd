class_name Cursor
extends Node2D

#Emitted ketika melakukan click pada cell yang sedang ditunjuk
signal accept_pressed(cell)
#Emitted ketika kursor bergerak ke cell baru
signal moved(new_cell)
#Waktu sebelum mouse dapat berpindah lagi

### PR BENARKAN CURSOR LOCATOR SESUAIKAN DENGAN TILEMAP### ->> DONE [v]
var cell := Vector2.ZERO:
	set(value):
		var new_cell: Vector2 = get_global_mouse_position()
		cell = new_cell

var is_visible := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	visible = is_visible

func _unhandled_input(event: InputEvent) -> void:
	# Navigating cells with the mouse (update cell baed on hovered mouse).
	if event is InputEventMouseMotion:
		cell = event.position
		emit_signal("moved", cell)
	# Trying to select something in a cell.
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		emit_signal("accept_pressed", cell)
# Called every frame. 'delta' is the elapsed time since the previous frame.
