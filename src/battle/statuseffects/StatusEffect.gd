# Represents and applies the effect of a given status to a battler.
# The status takes effect as soon as the node is added to the scene tree.
# @tags: virtual
class_name StatusEffect
# Our effects extend `Node` so we can use the `_process()`
# callback to update the effect on every frame.
extends Node

# Provided by the ActiveTurnQueue.
var time_scale := 1.0
# Duration of the effect in seconds, if necessary.
var duration_seconds := 0.0 setget set_duration_seconds
# If `true`, the effect applies once every `ticking_interval`
var is_ticking := false
# Duration between ticks in seconds.
var ticking_interval := 1.0
# If `true`, the effect is active and is applying.
var is_active := true setget set_is_active

# Text string to reference the effect and instantiate it. See `StatusEffectBuilder`.
var id := "base_effect"

# Time left in seconds until the effect expires.
var _time_left: float = -INF
# Time left in the current tick, if the effect is ticking.
var _ticking_clock := 0.0
# If `true`, this effect can stack.
var _can_stack := false
# Reference to the Battler to whom the effect is applied.
var _target


# We can't write type hints here due to cyclic loading errors in Godot 3.2.
# target: Battler
# data: StatusEffectData
func _init(target, data) -> void:
	_target = target
	set_duration_seconds(data.duration_seconds)

	# If the effect is ticking, we initialize the corresponding variables.
	is_ticking = data.is_ticking
	ticking_interval = data.ticking_interval
	_ticking_clock = ticking_interval


# Our status effects are nodes and they get into effect when added inside the battler's
# `StatusEffectContainer` node.
# `_start()` is a virtual method we'll override in derived classes.
func _ready() -> void:
	_start()


func _process(delta: float) -> void:
	_time_left -= delta * time_scale

	# If the effect is ticking, we want to know when we have to apply it. For example, for poison,
	# you want to inflict damage every `ticking_interval` seconds.
	if is_ticking:
		var old_clock = _ticking_clock
		# The `wrapf()` function cycles values between the second and the third argument. If
		# `ticking_interval` is `3.0` seconds and the expression evaluate to `-0.2`, the resulting
		# value will be `3.0 - 0.2 == 2.8`.
		_ticking_clock = wrapf(_ticking_clock - delta * time_scale, 0.0, ticking_interval)
		# When the value wraps, the ticking clock is greater than the `old_clock` and we apply the
		# effect.
		if _ticking_clock > old_clock:
			_apply()

	# The effect expires when there's no time left.
	if _time_left < 0.0:
		set_process(false)
		# This is another virtual method defined below.
		_expire()


func can_stack() -> bool:
	return _can_stack


func get_time_left() -> float:
	return _time_left


# By convention in this project, all methods starting with a leading underscore,
# like `_expire()` below, are considered pseudo-private. So we add an extra
# "public" method for other objects to cause the status effect to expire. You
# might want that, for example, if you have poison status and the player uses an
# antidote.
func expire() -> void:
	_expire()


func set_duration_seconds(value: float) -> void:
	duration_seconds = value
	_time_left = duration_seconds
	

func set_is_active(value) -> void:
	is_active = value
	set_process(is_active)


# Initializes the status effect on the battler.
# @tags: virtual
func _start() -> void:
	pass


# Applies the status effect to the battler. Used with ticking effects,
# for example, a poison status dealing damage every two seconds.
# @tags: virtual
func _apply() -> void:
	pass


# Cleans up and removes the status effect from the battler.
# The default behavior is to free the node.
func _expire() -> void:
	queue_free()

