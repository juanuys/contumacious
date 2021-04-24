# Abstract base class for all combat actions.
# Constructed from an [ActionData] resource
# Actions take an actor and an array of targets. The actor applies the action to the targets, which involves sequencing and playing animations.
# Because of that, actions rely on coroutines and must emit the signal "finished" when the action is over.
# See derived classes like [AttackAction] for concrete examples.
# Implements the Command pattern. For more information, see http://gameprogrammingpatterns.com/command.html
class_name Action
# Reference is the default type you extend in Godot, even if you omit this line.
# Godot allocates and frees instances of a Reference from memory for you.
extends Reference

# Emitted when the action finished playing.
signal finished

var _data: ActionData
var _actor
var _targets := []


# The constructor allows you to create actions from code like so:
# var action := Action.new(data, battler, targets)
func _init(data: ActionData, actor: Battler, targets: Array) -> void:
	_data = data
	_actor = actor
	_targets = targets


# Applies the action on the targets, using the actor's stats.
# Returns `true` if the action succeeded.
func apply_async() -> bool:
	
	return _apply_async()

# the convention for abstract methods in Godot is they should
# start with an underscore, but public methods should not.
# The "async" suffix means this is a coroutine (TODO animation)
func _apply_async() -> bool:
	# In the abstract base Action class, we don't do anything!
	emit_signal("finished")
	return true
	
# Returns `true` if the action should target opponents by default.
func targets_opponents() -> bool:
	return true

# The battler needs to know how much readiness they should retain after 
# performing the action.
func get_readiness_saved() -> float:
	return _data.readiness_saved

# Exposing the energy cost will allow us to highlight energy points an action
# will use in the energy bar.
func get_energy_cost() -> int:
	return _data.energy_cost


