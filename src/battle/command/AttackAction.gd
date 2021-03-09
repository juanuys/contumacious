# Concrete class for damaging attacks. Inflicts zero or more direct damage to 
# one or more targets. It can also apply status effects.
class_name AttackAction
extends Action

# We calculate and store hits in an array to consume later, in sync with the
# animation.
var _hits := []


# We must override the constructor to use it.
# Notice how _init() uses a unique notation to call the parent's constructor.
func _init(data: AttackActionData, actor, targets: Array).(data, actor, targets) -> void:
	pass



# Returns the damage dealt by this action. We will update this function
# when we implement status effects.
func calculate_potential_damage_for(target) -> int:
	return Formulas.calculate_base_damage(_data, _actor, target)


func _apply_async() -> bool:
	# We apply the action to each target so attacks work both for single and multiple targets.
	for target in _targets:
		var hit_chance := Formulas.calculate_hit_chance(_data, _actor, target)
		var damage := calculate_potential_damage_for(target)
		var hit := Hit.new(damage, hit_chance)
		# We're going to define a new function on the battler so it takes hits.
		target.take_hit(hit)
	# Our method is supposed to be a coroutine, that is to say, it pauses
	# execution and ends after some time.
	# in Godot 3.2, we do so using the `yield` keyword.
	# Here, we wait for the next frame by listening to the SceneTree's 
	# `idle_frame` signal.
	yield(Engine.get_main_loop(), "idle_frame")
	return true
