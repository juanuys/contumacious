class_name BattlerAI
extends Node

enum HealthStatus { CRITICAL, LOW, MEDIUM, HIGH, FULL }

# The actor that has this AI brain.
var _actor: Battler
# An array of battlers in the AI's party, including the `_actor`.
var _party := []
# An array of battlers that are in the opposing party.
var _opponents := []

# For each ActionData key, stores an array of opponents that are weak to this action.
var _weaknesses_dict := {}

var _rng := RandomNumberGenerator.new()

# Queue of [ActionData]. If not empty, the action is popped
# from this array on the next turn.
# Use this property to plan actions over multiple turns.
var _next_actions := []

# Filters and saves the list of party members and opponents.
func setup(actor: Battler, battlers: Array) -> void:
	_actor = actor
	for battler in battlers:
		var is_opponent: bool = battler.is_party_member != actor.is_party_member
		if is_opponent:
			_opponents.append(battler)
		else:
			_party.append(battler)
			
	_calculate_weaknesses()


func _calculate_weaknesses() -> void:
	for action in _actor.actions:
		# This initializes the dictionary `_weaknesses_dict`, creating a key for each `action`.
		_weaknesses_dict[action] = []
		for opponent in _opponents:
			# We loop over each action and opponent. If the opponent is weak to the action,
			# we store it in our list of weak opponents.
			if _is_weak_to(opponent, action):
				_weaknesses_dict[action].append(opponent)

# Finds key information about the state of the battle so the agent can take a decision.
func _gather_information() -> Dictionary:
	# filter available actions, that is, actions the agent can use this turn.
	var actions := _get_available_actions()
	var attack_actions := _get_attack_actions_from(actions)
	var defensive_actions := _get_defensive_actions_from(actions)

	# populate a dictionary with the information we want the agent to have.
	var info := {
		weakest_target = _get_battler_with_lowest_health(_opponents),
		weakest_ally = _get_battler_with_lowest_health(_party),
		health_status = _get_health_status(_actor),
		fallen_party_count = _count_fallen_party(),
		fallen_opponents_count = _count_fallen_opponents(),
		available_actions = actions,
		attack_actions = attack_actions,
		defensive_actions = defensive_actions,
		strongest_action = _find_most_damaging_action_from(attack_actions),
	}
	return info

# Returns an array of actions the agent can use this turn.
func _get_available_actions() -> Array:
	var actions := []
	# Note that `Battler.actions` is an array of `ActionData`.
	for action in _actor.actions:
		# We call `ActionData.can_be_used_by()` to ensure the agent can use the action this turn.
		if action.can_be_used_by(_actor):
			actions.append(action)
	return actions


# Returns actions of type `AttackActionData` in `available_actions`.
func _get_attack_actions_from(available_actions: Array) -> Array:
	var attack_actions := []
	for action in available_actions:
		if action is AttackActionData:
			attack_actions.append(action)
	return attack_actions


# Returns actions that are *not* of type `AttackActionData` in `available_actions`.
func _get_defensive_actions_from(available_actions: Array) -> Array:
	var defensive_actions := []
	for action in available_actions:
		if not action is AttackActionData:
			defensive_actions.append(action)
	return defensive_actions

# Returns the battler with the lowest health in the `battlers` array.
func _get_battler_with_lowest_health(battlers: Array) -> Battler:
	var weakest: Battler = battlers[0]
	# We loop over battlers and compare their health with the current lowest.
	for battler in battlers:
		# If the current battler has a lower health than `weakest`, we assign it to `weakest`.
		if battler.stats.health < weakest.stats.health:
			weakest = battler
	return weakest


# Returns `true` if the `battler`'s health is below a given ratio.
func _is_health_below(battler: Battler, ratio: float) -> bool:
	# We ensure the ratio is in the [0.0, 1.0] range.
	ratio = clamp(ratio, 0.0, 1.0)
	return battler.stats.health < battler.stats.max_health * ratio


# Returns a member of the `HealthStatus` enum depending of the agent's current health ratio.
func _get_health_status(battler: Battler) -> int:
	if _is_health_below(battler, 0.1):
		return HealthStatus.CRITICAL
	elif _is_health_below(battler, 0.3):
		return HealthStatus.LOW
	elif _is_health_below(battler, 0.6):
		return HealthStatus.MEDIUM
	elif _is_health_below(battler, 1.0):
		return HealthStatus.HIGH
	else:
		return HealthStatus.FULL


# Returns the count of fallen party members.
func _count_fallen_party() -> int:
	var count := 0
	for ally in _party:
		if ally.is_fallen():
			count += 1
	return count


# Returns the count of fallen opponents.
func _count_fallen_opponents() -> int:
	var count := 0
	for opponent in _opponents:
		if opponent.is_fallen():
			count += 1
	return count

# the most damaging attack action. Below, we only calculate theoretical
# maximum damage. We don’t account for a potential target’s
# defense or other stats like evasion (yet).
func _find_most_damaging_action_from(attack_actions: Array):
	var strongest_action
	# The strongest action is the one that will inflict the most
	# total damage, in theory.
	var highest_damage := 0
	for action in attack_actions:
		var total_damage = action.calculate_potential_damage_for(_actor)
		# We loop over all actions and always keep the one
		# with the highest potential damage.
		if total_damage > highest_damage:
			strongest_action = action
			highest_damage = total_damage
	return strongest_action

# Returns true if the `battler`'s health ratio is above `ratio`.
func _is_health_above(battler: Battler, ratio: float) -> bool:
	ratio = clamp(ratio, 0.0, 1.0)
	return battler.stats.health > battler.stats.max_health * ratio


# Returns `true` if the `battler` is weak to the `action`'s element.
func _is_weak_to(battler: Battler, action: ActionData) -> bool:
	return action.element in battler.stats.weaknesses

# Returns a dictionary representing an action and its targets.
# The dictionary has the form { action: Action, targets: Array[Battler] }
# Arguments:
# - `battlers: Array[Battler]`, all battlers on the field, including the actor
func choose() -> Dictionary:
	# A defensive assert to ensure we don't forget to call `setup()` on the AI during development.
	assert(
		not _opponents.empty(),
		"You must call setup() on the AI and give it opponents for it to work."
	)
	return _choose()


func _choose() -> Dictionary:
	# We start the turn by gathering information about the battlefield.
	var battle_info := _gather_information()

	# The values we need to return in our dictionary.
	var action: ActionData
	var targets := []
	
	if not _next_actions.empty():
		action = _next_actions.pop_front()
	else:
		action = _choose_action(battle_info)

	# There's a special case with actions, if it's targeting its user, we don't need
	# to choose a target.
	if action.is_targeting_self:
		targets = [_actor]
	else:
		targets = _choose_targets(action, battle_info)
	return {action = action, targets = targets}


# Virtual method. Returns the action the agent is choosing to use this turn.
func _choose_action(_info: Dictionary) -> ActionData:
	return _actor.actions[0]


# Virtual method. Returns the agent's targets this turn.
func _choose_targets(_action: ActionData, _info: Dictionary) -> Array:
	return [_info.weakest_target]
