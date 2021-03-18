class_name StatusEffectHaste
extends StatusEffect

# We give an explicit name to the value `StatusEffectData.effect_power` for this effect.
var speed_bonus := 0

# We're going to use our stats' class to add and remove a modifier.
var _stat_modifier_id := -1


# Below, target is of type `Battler`.
func _init(target, data: StatusEffectData).(target, data) -> void:
	# All haste effects should have the same `id` so we can later find and remove them.
	id = "haste"
	speed_bonus = data.effect_power


func _start() -> void:
	# We initialize the effect by adding a stat modifier to the target battler.
	_stat_modifier_id = _target.stats.add_modifier("speed", speed_bonus)


func _expire() -> void:
	# And we remove the stat modifier when the effect expires.
	_target.stats.remove_modifier("speed", _stat_modifier_id)
	queue_free()
