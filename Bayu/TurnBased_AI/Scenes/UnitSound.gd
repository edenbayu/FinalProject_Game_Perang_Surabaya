class_name UnitSound
extends Node2D

@onready var shoot = $Shoot
@onready var hurt = $Hurt
@onready var walk = $Walk

func play_shoot() -> void:
	shoot.play()

func play_hurt() -> void:
	hurt.play()

func play_walk() -> void:
	walk.playing = true

func stop_walk() -> void:
	walk.playing = false
