# Keeps track of status effects active on a [Battler].
# Adds and removes status effects as necessary.
# Intended to be placed as a child of a Battler.
class_name StatusEffectContainer
extends Node

# Maximum number of instances of one type of status effect that can be applied to one battler at a
# time.
const MAX_STACKS := 5
# List of effects that can be stacked.
const STACKING_EFFECTS := ["bug"]
# List of effects that cannot be stacked. When a new effect of this kind is applied, it replaces or
# refreshes the previous one.
const NON_STACKING_EFFECTS := ["haste", "slow"]

# The two properties below work the same way as with the `ActiveTurnQueue`.
# The setters assign the value to child nodes.
var time_scale := 1.0 setget set_time_scale
var is_active := true setget set_is_active


func _init():
	print("calling StatusEffectContainer init")
	
func _ready():
	print("calling StatusEffectContainer ready")

# Adds a new instance of a status effect as a child, ensuring the effects don't stack past
# `MAX_STACKS`.
func add(effect: StatusEffect) -> void:
	# If we already have active effects, we may have to replace one.
	# If it can stack, we replace the one with the smallest time left.
	if effect.can_stack():
		if _has_maximum_stacks_of(effect.id):
			_remove_effect_expiring_the_soonest(effect.id)
	# If it's a unique effect like slow or haste, we replace it.
	elif has_node(effect.name):
		# We call `StatusEffect.expire()` to let the effect properly clean up itself.
		get_node(effect.name).expire()
	# The status effects are node so all we need to do is add it as a child of the container.
	add_child(effect)


# Removes all stacks of an effect of a given type.
func remove_type(id: String) -> void:
	for effect in get_children():
		if effect.id == id:
			effect.expire()


# Removes all status effects.
func remove_all() -> void:
	for effect in get_children():
		effect.expire()


# The two setters below are similar to what we did in `ActiveTurnQueue.gd`
func set_time_scale(value: float) -> void:
	time_scale = value
	for effect in get_children():
		effect.time_scale = time_scale


func set_is_active(value) -> void:
	is_active = value
	for effect in get_children():
		effect.is_active = is_active


# Returns `true` if there are `MAX_STACKS` instances of a given status effect.
func _has_maximum_stacks_of(id: String) -> bool:
	var count := 0
	for effect in get_children():
		if effect.id == id:
			count += 1
	return count == MAX_STACKS


# Finds and expires the effect of a given type expiring the soonest.
func _remove_effect_expiring_the_soonest(id: String) -> void:
	var to_remove: StatusEffect
	var smallest_time: float = INF
	# We have to check all effects to find the ones that match the `id`.
	for effect in get_children():
		if effect.id != id:
			continue
		# We compare the `time_left` for an effect of type `id` to the current `smallest_time` and
		# if it's smaller, we update the variables.
		var time_left: float = effect.get_time_left()
		if time_left < smallest_time:
			to_remove = effect
			smallest_time = time_left
	to_remove.expire()
