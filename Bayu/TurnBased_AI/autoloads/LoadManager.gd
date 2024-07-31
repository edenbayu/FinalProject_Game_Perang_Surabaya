extends Node

signal progress_changed(progres)
signal load_done

var _load_screen_path: String = "res://LoadingScreen/loading_screen.tscn"
var _load_screen = load(_load_screen_path)
var _loaded_resources: PackedScene
var _scene_path: String

var use_sub_threads: bool = true

func load_scene(scene_path: String) -> void:
	_scene_path = scene_path
	
	var new_loading_screen = _load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	
	self.progress_changed.connect(new_loading_screen._update_progress_bar)
	self.load_done.connect(new_loading_screen._on_load_done)
	start_load()
		
func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(_scene_path)
	if state == OK:
		set_process(true)
			
func _process(_delta):
	var _progress = []
	var load_status = ResourceLoader.load_threaded_get_status(_scene_path, _progress)
	match load_status:
		0, 2:
			set_process(false)
			return
		1:
			emit_signal("progress_changed", _progress[0])
		3:
			emit_signal("progress_changed", 1.0)
			if Input.is_action_pressed("klik_mouse_kiri"):
				_loaded_resources = ResourceLoader.load_threaded_get(_scene_path)
				emit_signal("load_done")
				get_tree().change_scene_to_packed(_loaded_resources)
