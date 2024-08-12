class_name UnitSound
extends Node2D

@onready var shoot = $Shoot
@onready var hurt = $Hurt
@onready var walk = $Walk
@onready var bamboo = $Bamboo
@onready var reload = $Reload

func play_shoot() -> void:
	var parent = get_parent() as Unit
	if parent.nama == "Soerjo":
		shoot.play()
	elif parent.nama == "Arief":
		bamboo.play()
	else:
		shoot.play()

func play_hurt() -> void:
	hurt.play()

func play_walk() -> void:
	walk.playing = true

func stop_walk() -> void:
	walk.playing = false

func play_reload() -> void:
	reload.playing = true
