# Individual button representing one combat action.
extends TextureButton

# We store references to the nodes we access in the class, as usual.
onready var _icon_node: TextureRect = $HBoxContainer/Icon
onready var _label_node: Label = $HBoxContainer/Label


# To call from a parent UI widget. Initializes the button.
func setup(action: ActionData, can_be_used: bool) -> void:
	# In a parent node you may call `setup()` before adding the button as a child.
	# If that is the case, we need to pause execution until the button is ready.
	if not is_inside_tree():
		yield(self, "ready")
	# Only update the icon's texture if the action data inlcudes an icon.
	if action.icon:
		_icon_node.texture = action.icon
	_label_node.text = action.label
	# The button has no notion of the battler's energy and the action's cost.
	# We will tell it if the player can use the action or not. If not, the button should be disabled.
	disabled = not can_be_used


# When pressing the button, we release its focus. Doing so prevents the player from
# pressing two action buttons or from pressing one twice.
func _on_pressed() -> void:
	release_focus()
