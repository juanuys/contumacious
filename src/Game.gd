extends Node

const game_mode := "card"

func _ready():
	var fade_in = Tween.new()
	add_child(fade_in)
	var music = AudioStreamPlayer.new()
	add_child(music)
	var stream = load("res://assets/audio/music/CC3.ogg")
	music.set_stream(stream)
	music.pitch_scale = 1
	fade_in.interpolate_property(music, "volume_db", -80, -10, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	fade_in.start()
	yield(get_tree().create_timer(0.1), "timeout")
	music.play()
