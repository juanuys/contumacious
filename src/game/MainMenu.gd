extends Node2D

func _on_New_Game_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://src/cc/InheritedCoreMain.tscn")


func _on_LeaveFeedback_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open("https://juanuys.com/games/contumacious#feedback")


func _on_Exit_pressed():
	get_tree().quit()
