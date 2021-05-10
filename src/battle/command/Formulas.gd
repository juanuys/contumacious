class_name Formulas
extends Reference

# Returns the product of the attacker's attack and the action's multiplier.
static func calculate_potential_damage(action_data: ActionData, attacker) -> float:
	var potential_damage = attacker.stats.attack * action_data.damage * action_data.damage_multiplier
	print("calculate_potential_damage: %s * %s * %s = %s" % [attacker.stats.attack, action_data.damage, action_data.damage_multiplier, potential_damage])
	return potential_damage

# The base damage is "attacker.attack * action.multiplier - defender.defense".
# The function multiplies it by a weakness multiplier, calculated by
# `_calculate_weakness_multiplier` below. Finally, we ensure the value is an
# integer in the [1, 999] range.
static func calculate_base_damage(action_data: ActionData, attacker: Battler, defender: Battler) -> int:
	var damage: float = calculate_potential_damage(action_data, attacker)
	damage -= defender.stats.defense
	damage *= _calculate_weakness_multiplier(action_data, defender)
	return int(clamp(damage, 1.0, 999.0))

static func calculate_exponential_damage(action_data: ActionData, attacker: Battler, defender: Battler) -> int:
	var base_damage: float = pow(attacker.attack, 3.0) / 10.0 + 12.0 * attacker.attack + 48.0
	var damage_reduction: float = pow(defender.defense, 2.2)
	var damage: float = base_damage * action_data.damage_multiplier - damage_reduction
	return int(clamp(damage, 0.0, 99999.0))

# Calculates a multiplier based on the action and the defender's elements.
static func _calculate_weakness_multiplier(action_data, defender) -> float:
	var multiplier := 1.0
	var element: int = action_data.element
	if element != Types.Elements.NONE:
		# If the defender has an affinity with the action's element, the
		# multiplier should be 0.75
		if Types.WEAKNESS_MAPPING[defender.stats.affinity] == element:
			multiplier = 0.75
		# If the action's element is part of the defender's weaknesses, we
		# set the multiplier to 1.5
		elif Types.WEAKNESS_MAPPING[element] in defender.stats.weaknesses:
			multiplier = 1.5
	return multiplier


# The formula in pseudo-code:
# (attacker.hit_chance - defender.evasion) * action.hit_chance + affinity_bonus + element_triad_bonus - defender_affinity_bonus
static func calculate_hit_chance(action_data, attacker, defender) -> float:
	var chance: float = attacker.stats.hit_chance - defender.stats.evasion
	# The action's hit chance is a value between 0 and 100 for consistency with
	# the battlers' stats. As we use it as a multiplier here, we need to divide
	# it by 100 first.
	chance *= action_data.hit_chance / 100.0

	# Below, we use the new BattlerStats properties, `affinity` and `weaknesses`,
	# to apply a hit chance bonus or penalty.
	var element: int = action_data.element
	# If the action's element matches the attacker's affinity, we increase the
	# hit rating by 5.
	if element == attacker.stats.affinity:
		chance += 5.0
	if element != Types.Elements.NONE:
		# If the action's element is part of the defender's weaknesses, we
		# increase the hit rating by 10.
		if Types.WEAKNESS_MAPPING[element] in defender.stats.weaknesses:
			chance += 10.0
		# However, if the defender has an affinity with the action's element, we
		# decrease the hit rating by 10.
		if Types.WEAKNESS_MAPPING[defender.stats.affinity] == element:
			chance -= 10.0
	# Clamping the result ensures it's always in the [0, 100] range.
	return clamp(chance, 0.0, 100.0)

