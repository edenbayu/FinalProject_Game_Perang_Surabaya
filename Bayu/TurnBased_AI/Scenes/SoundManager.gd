class_name SoundManager
extends Node2D

@onready var hover_audio :AudioStreamPlayer2D = $hover
@onready var click : AudioStreamPlayer2D = $click
@onready var sound_dialog : AudioStreamPlayer2D = $bgds
@onready var nambu = $nambu
@onready var lvl_1_bgm = $lvl1_bgm
@onready var hurt = $hurt
@onready var sound_dialog2 = $sound_dialog2
@onready var sound_dialog3 = $sound_dialog3
@onready var lvl_2_bgm = $lvl2_bgm
@onready var victory = $victory
@onready var gugur_bunga = $gugur_bunga

func button_sound() -> void:
	hover_audio.play()

func click_sound() -> void:
	click.play() 

func sound_level1() -> void:
	sound_dialog.stream.loop = true
	sound_dialog.play()

func sound_level2() -> void:
	sound_dialog2.stream.loop = true
	sound_dialog2.play()
	
func sound_level3() -> void:
	sound_dialog3.stream.loop = true
	sound_dialog3.play()

func victory_sound() -> void:
	lvl_1_bgm.stop()
	lvl_2_bgm.stop()
	victory.play()

func nambu_shoot() -> void:
	nambu.play()

func level1_bgm(level) -> void:
	match level:
		1:
			lvl_1_bgm.stream.loop = true
			lvl_1_bgm.play()
		2:
			lvl_2_bgm.stream.loop = true
			lvl_2_bgm.play()
		6:
			gugur_bunga.stream.loop = true
			gugur_bunga.play()

func unit_hurt() -> void:
	hurt.play()
