class_name StatusEffectSlow
extends StatusEffect

var speed_reduction := 0.0 setget set_speed_rate

var _stat_modifier_id := -1


# Similar to `StatusEffectHaste`.
func _init(target, data: StatusEffectData).(target, data) -> void:
	id = "slow"
	speed_reduction = data.effect_rate


func _start() -> void:
	_stat_modifier_id = _target.stats.add_modifier(
		# We can calculate the modifier's value from the `speed_reduction` ratio.
		"speed", -1.0 * speed_reduction * _target.stats.speed
	)


# Same as `StatusEffectHaste`.
func _expire() -> void:
	_target.stats.remove_modifier("speed", _stat_modifier_id)
	queue_free()


# We ensure the speed reduction is neither 0% nor greater than 99%.
func set_speed_rate(value: float) -> void:
	speed_reduction = clamp(value, 0.01, 0.99)
