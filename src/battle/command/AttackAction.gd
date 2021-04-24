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


func _apply_async() -> bool:
	# We're going to access the BattlerAnim node directly from the action. We could define
	# a `Battler.play()` method instead to encapsulate it completely, but the action
	# is an object representing a method call on the battler, in a sense.
	var anim = _actor.battler_anim

	# We apply the action to each target so attacks work both for single and multiple targets.
	for target in _targets:
		# We use the `StatusEffectBuilder` to instantiate the right effect.
		var status: StatusEffect = StatusEffectBuilder.create_status_effect(
			target, _data.status_effect
		)
		var hit_chance := Formulas.calculate_hit_chance(_data, _actor, target)
		var damage := calculate_hit_damage(target)
		var hit := Hit.new(damage, hit_chance, status)

		# Here's how we use the animations' `triggered` signal. We bind the target and each hit
		# to the `_on_BattlerAnim_triggered()` callback.
		anim.connect("triggered", self, "_on_BattlerAnim_triggered", [target, hit])
		# Then, we play the animation, which will later emit the `triggered` signal.
		anim.play("attack")
		yield(_actor, "animation_finished")
	return true

func calculate_hit_damage(target) -> int:
	return Formulas.calculate_base_damage(_data, _actor, target)

func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
	# On each animation trigger, we apply the corresponding hit.
	target.take_hit(hit)
