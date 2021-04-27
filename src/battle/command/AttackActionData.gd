# Data container used to construct [AttackAction] objects.
class_name AttackActionData
extends ActionData

# Multiplier applied to the calculated attack damage.
export var damage_multiplier := 1.0
# Hit chance rating for this attack. Works as a rate: a value of 90 means the
# action has a 90% chance to hit.
export var hit_chance := 100.0
# Status effect applied by the attack, of type `StatusEffectData`.
export var status_effect: Resource

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.

func _init(
	p_damage_multiplier = 1.0,
	p_hit_chance = 100.0,
	p_status_effect = null,
	
	p_energy_cost = 0,
	p_damage = 1.0,
	p_element = Elements.NONE,
	p_is_targeting_self = false,
	p_is_targeting_all = false,
	p_readiness_saved = 0.0,
	p_label = "Base combat action"
	).(p_energy_cost, p_damage, p_element, p_is_targeting_self, p_is_targeting_all, p_readiness_saved, p_label):
		
	damage_multiplier = p_damage_multiplier
	hit_chance = p_hit_chance
	status_effect = p_status_effect


# Returns the total damage for the action, factoring in damage dealt by a status effect.
func calculate_potential_damage_for(battler) -> int:
	var total_damage: int = int(Formulas.calculate_potential_damage(self, battler))
	# Adding the effect's damage if applicable.
	if status_effect:
		total_damage += status_effect.calculate_total_damage()
	return total_damage
