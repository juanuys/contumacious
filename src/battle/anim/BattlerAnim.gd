# We use the tool mode here so the node's `scale` updates when we change the battler's direction. See `direction` below.
tool
# Hold and plays the base animation for battlers.
class_name BattlerAnim
extends Position2D

# Forwards the animation players' `animation_finished` signal.
signal animation_finished(name)
# Emitted by animations when a combat action should apply its next effect, like dealing damage or healing an ally.
signal triggered


# There are two directions a battler can look: left or right.
enum Direction { LEFT, RIGHT }

# Controls the direction in which the battler looks and moves.
# In `set_direction()`, we change the node's `scale.x` based on this property's valie.
export (Direction) var direction := Direction.RIGHT setget set_direction

# We store the node's start position to reset it using the `Tween` node.
var _position_start := Vector2.ZERO


onready var anim_player: AnimationPlayer = $Pivot/AnimationPlayer
onready var anim_player_damage: AnimationPlayer = $Pivot/AnimationPlayerDamage
onready var tween: Tween = $Tween
onready var _anchor_front: Position2D = $FrontAnchor
onready var _anchor_top: Position2D = $TopAnchor
onready var _anchor_bottom: Position2D = $BottomAnchor

func _ready() -> void:
	_position_start = position



# Functions that wraps around the animation players' `play()` function, delegating the work to the
# `AnimationPlayerDamage` node when necessary.
func play(anim_name: String) -> void:
	if anim_name == "take_damage":
		anim_player_damage.play(anim_name)
		# Seeking back to 0 restarts the animation if it is already playing.
		anim_player_damage.seek(0.0)
	else:
		anim_player.play(anim_name)


# Wraps around `AnimationPlayer.is_playing()`
func is_playing() -> bool:
	return anim_player.is_playing()


# Queues the animation and plays it if the animation player is stopped.
func queue_animation(anim_name: String) -> void:
	anim_player.queue(anim_name)
	if not anim_player.is_playing():
		anim_player.play()

# The following two functions use the tween node to move the character forward and back.
# We'll use this to emphasize the start and end of a battler's turn.
func move_forward() -> void:
	# The call below animates the node's position forward over `0.3` seconds.
	tween.interpolate_property(
		self,
		"position",
		position,
		# We use `scale.x` to control the direction the node is facing.
		position + Vector2.LEFT * scale.x * 40.0,
		0.3,
		Tween.TRANS_QUART,
		Tween.EASE_IN_OUT
	)
	# Don't forget to start a tween or a series of tweens after defining them.
	# No animation happens until you do so.
	tween.start()


# Moves the node to `_position_start`
func move_back() -> void:
	# Note that you may want to stop other tweens affecting the node's `position` in a different context.
	# In general, you want to ensure that previous tweens affecting a given property ended before starting a new one.
	# Due to the game's turn-based nature and how we will sequence animations, we don't need to stop
	# previous tweens here.
	tween.interpolate_property(
		self, "position", position, _position_start, 0.3, Tween.TRANS_QUART, Tween.EASE_IN_OUT
	)
	tween.start()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	emit_signal("animation_finished", anim_name)

func set_direction(value: int):
	direction = value
	scale.x = -1.0 if direction == Direction.RIGHT else 1.0

func get_front_anchor_global_position() -> Vector2:
	return _anchor_front.global_position
	
	
func get_top_anchor_global_position() -> Vector2:
	return _anchor_top.global_position

func get_bottom_anchor_global_position() -> Vector2:
	return _anchor_bottom.global_position
	
