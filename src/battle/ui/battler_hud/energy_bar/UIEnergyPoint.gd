# Represents one energy point. This node has two animations and functions to make it appear and
# disappear smoothly.
extends TextureRect

# This represents a target offset when selecting the point and tweening the node's position.
const POSITION_SELECTED := Vector2(0.0, -6.0)

# All our animations affect the `Fill` node.
onready var _fill: TextureRect = $Fill
onready var _tween: Tween = $Tween

# We store the start modulate value of the `Fill` node because it's semi-transparent.
# This way, we can animate the color from and to this value.
onready var _color_transparent := _fill.modulate


func appear() -> void:
	# We animate the `Fill` node's color from `_color_transparent` to a fully opaque white for `0.3
	# seconds`.
	_tween.interpolate_property(_fill, "modulate", _color_transparent, Color.white, 0.3)
	_tween.start()


func disappear() -> void:
	# This is the opposite of the appear animation, going from the fill's current `modulate` value
	# to `_color_transparent`.
	_tween.interpolate_property(_fill, "modulate", _fill.modulate, _color_transparent, 0.3)
	_tween.start()


func select() -> void:
	# This animation offsets the node to `POSITION_SELECTED`. The "out" easing means the animation
	# starts at full speed and slows down as it reaches the target position.
	_tween.interpolate_property(_fill, "rect_position", Vector2.ZERO, POSITION_SELECTED, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()


func deselect() -> void:
	# This is the opposite of the select animation.
	_tween.interpolate_property(_fill, "rect_position", POSITION_SELECTED, Vector2.ZERO, 0.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	_tween.start()
