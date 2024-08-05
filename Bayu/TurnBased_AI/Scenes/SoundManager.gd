class_name SoundManager
extends Node2D

@onready var hover_audio :AudioStreamPlayer2D = $hover
@onready var click : AudioStreamPlayer2D = $click
@onready var sound_dialog : AudioStreamPlayer2D = $bgds
@onready var nambu = $nambu
@onready var lvl_1_bgm = $lvl1_bgm
@onready var hurt = $hurt

func button_sound() -> void:
	hover_audio.play()

func click_sound() -> void:
	click.play() 

func sound_level1() -> void:
	sound_dialog.stream.loop = true
	sound_dialog.play()

func nambu_shoot() -> void:
	nambu.play()

func level1_bgm() -> void:
	lvl_1_bgm.stream.loop = true
	lvl_1_bgm.play()

func unit_hurt() -> void:
	hurt.play()
