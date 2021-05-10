extends AudioStreamPlayer

var assets = []
func _ready():
	var path = "res://assets/audio/sfx/attacks"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
			assets.append(load(path + "/" + file_name))
	dir.list_dir_end()

func play_sound():
	if not assets.empty():
		var asset = assets[randi() % assets.size()]
		self.stream.audio_stream = asset
		self.play()
