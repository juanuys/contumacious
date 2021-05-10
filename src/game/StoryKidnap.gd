extends Node2D

onready var tween = $Tween

func _ready():
	tween.interpolate_property($kidnap, "modulate:a", 1.0, 0.0, 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN, 3.0)
	tween.start()
	yield(tween, "tween_completed")
	
	get_tree().change_scene("res://src/cc/InheritedCoreMain.tscn")
