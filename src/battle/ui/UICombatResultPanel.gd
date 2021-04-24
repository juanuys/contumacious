# The tool mode allows us to update the label's text without directly accessing the node.
tool
extends Panel

# We expose a text property to encapsulate the label in the scene.
export var text := "" setget set_text

onready var _label: Label = $Label
onready var _anim_player: AnimationPlayer = $AnimationPlayer


func set_text(value: String) -> void:
	text = value
	# As usual, we have to wait for the node to be ready before we update the label.
	if not is_inside_tree():
		yield(self, "ready")
	_label.text = text


# And here are our fade animations.
func fade_in() -> void:
	_anim_player.play("fade_in")


func fade_out() -> void:
	_anim_player.play("fade_out")
