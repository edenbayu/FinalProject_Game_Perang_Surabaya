class_name UnitSound
extends Node2D

@onready var shoot = $Shoot
@onready var hurt = $Hurt
@onready var walk = $Walk
@onready var bamboo = $Bamboo
@onready var reload = $Reload
@onready var hurt_2 = $Hurt2
@onready var hurt_3 = $Hurt3

func play_shoot() -> void:
	var parent = get_parent() as Unit
	if parent.nama == "Soerjo":
		shoot.play()
	elif parent.nama == "Arief":
		bamboo.play()
	else:
		shoot.play()

func play_hurt() -> void:
	var random = randi() % 3
	match random:
		0:
			hurt.play()
		1:
			hurt_2.play()
		2:
			hurt_3.play()

func play_walk() -> void:
	walk.playing = true

func stop_walk() -> void:
	walk.playing = false

func play_reload() -> void:
	reload.playing = true
