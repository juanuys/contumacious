# Timeline representing the turn order of all battlers in the arena.
# Battler icons move along the timeline as their readiness updates.
extends Control

# You can preload scenes with relative paths when they're in the same directory. The line below will
# work as long as `UIBattlerIcon.tscn` is in the same directory as `UITurnBar.gd`.
# When there's only one scene meant to be instanced by another, I like to preload it like that
# instead of using an `export var`.
const BattlerIcon := preload("UIBattlerIcon.tscn")

onready var _background: TextureRect = $Background
onready var _anim_player: AnimationPlayer = $AnimationPlayer


# To initialize the turn bar, we pass all the battlers we want to display.
func setup(battlers: Array) -> void:
	for battler in battlers:
		# We first calculate the right icon background using the `Types` enum from `UIBattlerIcon`.
		# Below, I'm using the ternary operator. It picks the first value if the condition is `true`,
		# otherwise, it picks the second value.
		var type: int = (
			UIBattlerIcon.Types.PLAYER
			if battler.is_party_member
			else UIBattlerIcon.Types.ENEMY
		)
		# We create an instance of the `UIBattlerIcon` scene using a function and add it as a child.
		var icon: UIBattlerIcon = create_icon(type, battler.ui_data.texture)
		# We get to use the `Battler.readiness_changed` signal again to move the icons along the turn bar.
		# Once again, we bind the icon to the callback for each battler, so we don't have to worry
		# about which battler corresponds to which icon later.
		battler.connect("readiness_changed", self, "_on_Battler_readiness_changed", [icon])
		_background.add_child(icon)


# Creates a new instance of `UIBattlerIcon`, initializes it, adds it as a child of `background`, and
# returns it.
func create_icon(type: int, texture: Texture) -> UIBattlerIcon:
	var icon: UIBattlerIcon = BattlerIcon.instance()
	icon.icon = texture
	icon.type = type
	# We calculate where to position the icon, ranging between the left and right limits of the
	# `background` texture. Note this range is only in the X axis: the vector's X and Y components are
	# the minimum and the maximum icon's X position.
	icon.position_range = Vector2(
		# TextureRect nodes have their pivot and origin in the top-left corner, so we need to offset
		# the scale by half the icon's size.
		-icon.rect_size.x / 2.0,
		-icon.rect_size.x / 2.0 + _background.rect_size.x
	)
	return icon


# The following two functions encapsulate animation playback and the animation player.
func fade_in() -> void:
	_anim_player.play("fade_in")


func fade_out() -> void:
	_anim_player.play("fade_out")


# This is where we update the position of each icon. Every time a battler emits the
# "readiness_changed" signal, we use this value to snap the corresponding icon to a new location.
func _on_Battler_readiness_changed(readiness: float, icon: UIBattlerIcon) -> void:
	# We call the `UIBattlerIcon.snap()` function we defined previously. I recommend using a
	# function or dedicated property here because polishing the game, you might want to animate the
	# icon's movement.
	icon.snap(readiness / 100.0)
