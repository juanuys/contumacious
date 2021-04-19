# Icon representing a battler on the `UITurnBar`.
# The turn bar moves the icons as the associated battler's readiness updates.
# The tool mode allows us to encapsulate the node's icon texture and see it update in the viewport.
tool
class_name UIBattlerIcon
extends TextureRect

# We use this enum in the `type` exported variable below to get a drop-down menu in the Inspector.
# In the game, we can have ally AI, enemy AI, and player-controlled battlers.
enum Types { ALLY, PLAYER, ENEMY }

# This constant maps members of the Types enum to a texture.
const TYPES := {
	Types.ALLY: preload("res://assets/icons/icon_frame.png"),
	Types.PLAYER: preload("res://assets/icons/icon_frame.png"),
	Types.ENEMY: preload("res://assets/icons/icon_frame.png"),
}

# The following two properties allow you to update the icon and the background.
# The setter functions update the TextureRect nodes. This works both in-game and in the editor
# thanks to the `tool` mode.
export var icon: Texture setget set_icon
export (Types) var type: int = Types.ENEMY setget set_type

# Range of the icon's horizontal position to move it along the turn bar.
# The vector's `x` value is the minimum position, and the `y` component is its maximum.
var position_range := Vector2.ZERO

onready var _icon_node := $Icon


# Linearly interpolates the `x` position within the `position_range`.
# The `ratio` below is a value between 0 and 1.
func snap(ratio: float) -> void:
	rect_position.x = lerp(position_range.x, position_range.y, ratio)


# Updates the icon's texture.
func set_icon(value: Texture) -> void:
	icon = value
	# Setters get called when the engine creates the object, before adding it to the scene tree. At
	# this point, the `icon` variable is `null` and we can't set the texture. We can wait for the
	# node to finish its `_ready()` callback to ensure that the `_icon_node` is set.
	if not is_inside_tree():
		yield(self, "ready")
	_icon_node.texture = icon


# Updates the background texture using our `TYPES` dictionary.
func set_type(value: int) -> void:
	type = value
	texture = TYPES[type]
