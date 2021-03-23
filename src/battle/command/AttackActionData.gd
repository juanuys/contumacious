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

# Returns the total damage for the action, factoring in damage dealt by a status effect.
func calculate_potential_damage_for(battler) -> int:
	var total_damage: int = int(Formulas.calculate_potential_damage(self, battler))
	# Adding the effect's damage if applicable.
	if status_effect:
		total_damage += status_effect.calculate_total_damage()
	return total_damage
