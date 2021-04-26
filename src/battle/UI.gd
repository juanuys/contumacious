extends CanvasLayer

# We preload the `UICombatResultPanel` scene.
const UICombatResultPanel: PackedScene = preload("ui/UICombatResultPanel.tscn")

const UIAlertPanel: PackedScene = preload("ui/UIAlertPanel.tscn")

# And when the combat ends, we create an instance of it.
func _on_Combat_combat_ended(message) -> void:
	var widget: Control = UICombatResultPanel.instance()
	widget.text = message
	add_child(widget)

func _on_ActiveTurnQueue_player_turn_started(message) -> void:
	var widget: Control = UIAlertPanel.instance()
	widget.text = message
	add_child(widget)
