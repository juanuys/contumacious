extends CanvasLayer

# We preload the `UICombatResultPanel` scene.
const UICombatResultPanel: PackedScene = preload("ui/UICombatResultPanel.tscn")


# And when the combat ends, we create an instance of it.
func _on_Combat_combat_ended(message) -> void:
	var widget: Control = UICombatResultPanel.instance()
	widget.text = message
	add_child(widget)
