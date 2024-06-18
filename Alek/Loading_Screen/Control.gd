extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request("res://Loading_screen/level 1/level_1.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var progress = []
	ResourceLoader.load_threaded_get_status("res://Loading_screen/level 1/level_1.tscn", progress)
	$Label.text = str(progress[0]*100) + "%"
	print(progress[0]*100)
	
	#if progress[0] == 1:
		#var packed_scene = ResourceLoader.load_threaded_get("res://Loading_screen/level 1/level_1.tscn")
		#get_tree().change_scene_to_packed(packed_scene)
