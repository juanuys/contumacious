extends Resource
class_name BattlerStats


# Emitted when a character has no `health` left.
signal health_depleted
# Emitted every time the value of `health` changes.
# We will use it to animate the life bar.
signal health_changed(old_value, new_value)
# Same as above, but for the `energy`.
signal energy_changed(old_value, new_value)


# The battler's maximum health.
export var max_health := 100.0
export var max_energy := 6

# Note that due to how Resources work, in Godot 3.2, health will not have a
# value of `max_health`. This is why we have the function `reinitialize()`
# below. Each battler should call it when the encounter starts.
# This happens because a resource's initialization happens when you create it 
# in the editor serialize it, not when you load it in the game.
var health := max_health setget set_health
var energy := 0 setget set_energy


# A list of all properties that can receive bonuses.
const UPGRADABLE_STATS = [
	"max_health", "max_energy", "attack", "defense", "speed", "hit_chance", "evasion"
]

# The property below stores a list of modifiers for each property listed in
# `UPGRADABLE_STATS`.
# The value of a modifier can be any floating-point value, positive or negative.
var _modifiers := {}


# Initializes keys in the modifiers dict, ensuring they all exist.
func _init() -> void:
	for stat in UPGRADABLE_STATS:
		# For each stat, we create an empty dictionary.
		# Each upgrade will be a unique key-value pair.
		# We can have value-based and rate-based modifiers,
		# e.g. add 20 to attack, and boost attack by 50%
		_modifiers[stat] = {
			value = {},
			rate = {},
		}
		

func reinitialize() -> void:
	set_health(max_health)


func set_health(value: float) -> void:
	var health_previous := health
	# We use `clamp()` to ensure the value is always in the [0.0, max_health]
	# interval.
	health = clamp(value, 0.0, max_health)
	emit_signal("health_changed", health_previous, health)
	# As we are working with decimal values, using the `==` operator for
	# comparisons isn't safe. Instead, we need to call `is_equal_approx()`.
	if is_equal_approx(health, 0.0):
		emit_signal("health_depleted")


func set_energy(value: int) -> void:
	var energy_previous := energy
	# Energy works with whole numbers in this demo but the `clamp()` function
	# returns a floating-point value. You can let the compiler cast the value to
	# an integer, which will trigger a warning. I prefer to always do it
	# explicitly to remind myself that I'm working with integers here.
	energy = int(clamp(value, 0.0, max_energy))
	emit_signal("energy_changed", energy_previous, energy)


# attack/defense will be replaced with the values in the cards.
export var base_attack := 10.0 setget set_base_attack
export var base_defense := 10.0 setget set_base_defense
export var base_speed := 70.0 setget set_base_speed
export var base_hit_chance := 100.0 setget set_base_hit_chance
export var base_evasion := 0.0 setget set_base_evasion

# The values below are meant to be read-only.
var attack := base_attack
var defense := base_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion

# An array of elements against which the battler is weak.
# These weaknesses should be values from our `Types.Elements` enum.
export var weaknesses := []
# The battler's elemental affinity. Gives bonuses with related actions.
export var affinity: int = Types.Elements.NONE

# TODO There are ways to avoid writing these repetitive setter functions
# or defining separate base and final stats. You’ll find an example in 
# the course’s appendix at the end of this series. That’s a different 
# stats implementation from our 2D space game that uses 
# Object.get_property_list() to find stats from the object’s properties 
# procedurally.
func set_base_attack(value: float) -> void:
	base_attack = value
	_recalculate_and_update("attack")


func set_base_defense(value: float) -> void:
	base_defense = value
	_recalculate_and_update("defense")


func set_base_speed(value: float) -> void:
	base_speed = value
	_recalculate_and_update("speed")


func set_base_hit_chance(value: float) -> void:
	base_hit_chance = value
	_recalculate_and_update("hit_chance")


func set_base_evasion(value: float) -> void:
	base_evasion = value
	_recalculate_and_update("evasion")


# Calculates the final value of a single stat. That is, its based value
# with all modifiers applied.
# We reference a stat property name using a string here and update
# it with the `set()` method.
func _recalculate_and_update(stat: String) -> void:
	# All our property names follow a pattern: the base stat has the
	# same identifier as the final stat with the "base_" prefix.
	var value: float = get("base_" + stat)
	
	# We first get and sum all rate-based multipliers.
	var modifiers_multiplier: Array = _modifiers[stat]["rate"].values()
	var multiplier := 1.0
	for modifier in modifiers_multiplier:
		multiplier += modifier
	# Then, we multiply the base stat's value, if necessary.
	if not is_equal_approx(multiplier, 1.0):
		value *= multiplier

	# And we add all value-based modifiers.
	var modifiers_value: Array = _modifiers[stat]["value"].values()
	for modifier in modifiers_value:
		value += modifier

	value = round(max(value, 0.0))
	
	# Here's where we assign the value to the stat. For instance,
	# if the `stat` argument is "attack", this is like writing
	# attack = value
	set(stat, value)


# Adds a value-based modifier. The value gets added to the stat `stat_name` after applying
# rate-based modifiers.
func add_value_modifier(stat_name: String, value: float) -> void:
	# I miss some features from languages like Python here, that would allow for a more explicit 
	# syntax.
	_add_modifier(stat_name, value, 0.0)


# Adds a rate-based modifier. A value of `0.2` represents an increase in 20% of the stat `stat_name`.
func add_rate_modifier(stat_name: String, rate: float) -> void:
	_add_modifier(stat_name, 0.0, rate)


# Adds either a value-based or a rate-based modifier. Notice I'm using a third argument with a 
# default value of `0.0`.
func _add_modifier(stat_name: String, value: float, rate := 0.0) -> int:
	assert(stat_name in UPGRADABLE_STATS, "Trying to add a modifier to a nonexistent stat.")
	var id := -1

	# If the argument `value` is not `0.0`, we register a value-based modifier.
	if not is_equal_approx(value, 0.0):
		# Generates a new unique id for the "value" key.
		id = _generate_unique_id(stat_name, "value")
		_modifiers[stat_name]["value"][id] = value
	# If the argument `value` is not `0.0`, we register a rate-based modifier.
	if not is_equal_approx(rate, 0.0):
		# Generates a new unique id for the "rate" key.
		id = _generate_unique_id(stat_name, "rate")
		_modifiers[stat_name]["rate"][id] = rate

	_recalculate_and_update(stat_name)
	return id


# Removes a modifier associated with the given `stat_name`.
func remove_modifier(stat_name: String, id: int) -> void:
	# As above, during development, we want to know if we try to remove a
	# modifier that doesn't exist.
	assert(id in _modifiers[stat_name], "Id %s not found in %s" % [id, _modifiers[stat_name]])
	# Here's why we use dictionaries in `_modifiers`: we can arbitrarily erase
	# keys without affecting others, ensuring our unique IDs always work.
	_modifiers[stat_name].erase(id)
	_recalculate_and_update(stat_name)


# Find the first unused integer in a stat's modifiers keys.
func _generate_unique_id(stat_name: String, stat_type: String) -> int:
	var keys: Array = _modifiers[stat_name][stat_type].keys()
	# If there are no keys, we return `0`, which is our first valid unique id.
	# Without existing keys, calling methods like `Array.back()` will trigger an
	# error.
	if keys.empty():
		return 0
	else:
		# We always start from the last key, which will always be the highest
		# number, even if we remove modifiers.
		return keys.back() + 1
