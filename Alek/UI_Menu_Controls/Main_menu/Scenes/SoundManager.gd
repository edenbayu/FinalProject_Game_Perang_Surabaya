class_name SoundManager
extends Node2D

@onready var hover_audio :AudioStreamPlayer2D = $hover
@onready var click : AudioStreamPlayer2D = $click
@onready var sound_dialog : AudioStreamPlayer2D = $bgds

func button_sound() -> void:
	hover_audio.play()

func click_sound() -> void:
	click.play()

func sound_level1() -> void:
	sound_dialog.stream.loop = true
	sound_dialog.play()
