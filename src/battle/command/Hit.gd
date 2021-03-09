# Represents a damage-dealing hit to be applied to a target Battler.
# Encapsulates calculations for how hits are applied based on some properties.

# There are two main reasons to bother using a class like Hit:
# - It allows and forces you to pass a single value to the battler when it should take damage.
# - It encapsulates only the information the battler needs to know about the attack’s effect.
class_name Hit
extends Reference

# The damage dealt by the hit.
var damage := 0
# Chance to hit in base 100.
var hit_chance: float


func _init(_damage: int, _hit_chance := 100.0) -> void:
	damage = _damage
	hit_chance = _hit_chance


# Returns true if the hit isn't missing. To use when consuming the hit.
func does_hit() -> bool:
	return randf() * 100.0 < hit_chance
