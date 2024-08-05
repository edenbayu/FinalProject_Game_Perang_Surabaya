class_name UnitSound
extends Node2D

@onready var shoot = $Shoot
@onready var hurt = $Hurt

func play_shoot() -> void:
	shoot.play()

func play_hurt() -> void:
	hurt.play()
