# Queues and delegates turns for all battlers.
class_name ActiveTurnQueue
extends Node

var _party_members := []
var _opponents := []

# All battlers in the encounter are children of this node.
# We can get a list of all of them with get_children()
onready var battlers := get_children()

# Allows pausing the Active Time Battle during combat intro, a cutscene, or combat end.
var is_active := true setget set_is_active
# Multiplier for the global pace of battle, to slow down time while
# the player is making decisions.
# This is meant for accessibility and to control difficulty.
var time_scale := 1.0 setget set_time_scale

# Emitted when a player-controlled battler finished playing a turn, that is, when
# the `_play_turn()` function returns.
# We're going to use it to play the next battler's turn.
signal player_turn_finished

# If `true`, the player is currently playing a turn
var _is_player_playing := false
# Stack of player-controlled battlers that have to take turns.
var _queue_player := []

# Stores a reference to the UIActionMenu scene. You have to assign it in the Inspector.
export var UIActionMenuScene: PackedScene


func _ready() -> void:
	# to start the next turn.
	connect("player_turn_finished", self, "_on_player_turn_finished")
	
	for battler in battlers:
		# Setting up all AI-powered agents.
		battler.setup(battlers)
		
		# Listen to each battler's ready_to_act signal,
		# binding a reference to the battler to the callback.
		battler.connect("ready_to_act", self, "_on_Battler_ready_to_act", [battler])

		if battler.is_player_controlled():
			_party_members.append(battler)
		else:
			_opponents.append(battler)

func set_is_active(value: bool) -> void:
	is_active = value
	for battler in battlers:
		battler.is_active = is_active

# [0.0, 1.0] range
func set_time_scale(value: float) -> void:
	time_scale = value
	for battler in battlers:
		battler.time_scale = time_scale

# receives battlers that reached a _readiness of 100.
func _on_Battler_ready_to_act(battler: Battler) -> void:
	# If the battler is controlled by the player but another
	# player-controlled battler is in the middle of a turn,
	# we add this one to the queue.
	if battler.is_player_controlled() and _is_player_playing:
		_queue_player.append(battler)
	# Otherwise, it's an AI-controlled battler or the player is
	# waiting for a turn, and we can call `_play_turn()`.
	else:
		_play_turn(battler)

func _play_turn(battler: Battler) -> void:
	var action_data: ActionData
	var targets := []
	
	battler.stats.energy += 1
	# Makes every battler step forward at the start of their turn.
	# With player-controlled battlers, this helps to highlight the active character.
	battler.is_selected = true

	# The code below makes a list of selectable targets using `Battler.is_selectable`
	var potential_targets := []
	var opponents := _opponents if battler.is_party_member else _party_members
	for opponent in opponents:
		if opponent.is_selectable:
			potential_targets.append(opponent)

	if battler.is_player_controlled():
		# We'll use the selection to move playable battlers
		# forward. This value will also make the Heads-Up Display (HUD) for this
		# battler move forward.
		battler.is_selected = true
		# This line slows down time while the player selects an action and
		# target. The function `set_time_scale()` recursively assigns that value
		# to all characters on the battlefield.
		set_time_scale(0.05)
		
		# this is the start of a player-controlled battler's turn.
		_is_player_playing = true

		# Here is the meat of the player's turn. We use a while loop to wait for
		# the player to select a valid action and target(s).
		#
		# For now, we have two boilerplate asynchronous functions,
		# `_player_select_action_async()` and `_player_select_targets_async()`,
		# that respectively return an action to perform and an array of targets.
		# This seemingly complex setup will allow the player to cancel
		# operations in menus.
		var is_selection_complete := false
		# The loop keeps running until the player selected an action and target.
		while not is_selection_complete:
			# The player has to first select an action, then a target.
			# We store the selected action in the `action_data` variable defined
			# at the start of the function.
			action_data = yield(_player_select_action_async(battler), "completed")
			# If an action applies an effect to the battler only, we
			# automatically set it as the target.
			if action_data.is_targeting_self:
				targets = [battler]
			else:
				targets = yield(
					_player_select_targets_async(action_data, potential_targets), "completed"
				)
				
				# We want to clear the energy cost preview every 
				# time the player finished using the selection arrow.
				Events.emit_signal("player_target_selection_done")
				
			# If the player selected a correct action and target, we can break
			# out of the loop. I'm using a variable here to make the code
			# readable and clear. You could write a `while true` loop and use
			# the break keyword instead, but doing so makes the code less
			# explicit.
			is_selection_complete = action_data != null && targets != []
		# The player-controlled battler is ready to act. We reset the time scale
		# and deselect the battler.
		set_time_scale(1.0)
		battler.is_selected = false
	
	else:
		# TODO hard-coded for now
		# action_data = battler.actions[0]
		# targets = [potential_targets[0]]
		
		# Letting the AI choose by calling its `choose()` method.
		var result: Dictionary = battler.get_ai().choose()
		action_data = result.action
		targets = result.targets
		print("%s attacks %s with action %s" % [battler.name, targets[0].name, action_data.label])
	
	# Create a new attack action based on the chosen `action_data` and `targets`.
	var action = AttackAction.new(action_data, battler, targets)
	# And let the battler consume it.
	battler.act(action)
	
	# We wait for the battler's action to finish to complete the function.
	yield(battler, "action_finished")
	
	# At the very end of the function, if it's a player-controlled battler ending their turn, we emit our new signal.
	if battler.is_player_controlled():
		emit_signal("player_turn_finished")

func _player_select_action_async(battler: Battler) -> ActionData:
	
	# yield(get_tree(), "idle_frame")
	# return battler.actions[0]
	
	# Every time the player has to select an action in the turn loop, we instantiate the menu.
	# TODO disable the menu, and let the player just play a card.
	var action_menu: UIActionMenu = UIActionMenuScene.instance()
	add_child(action_menu)
	# Calling its `open` method makes it appear and populates it with action buttons.
	action_menu.open(battler)
	# We then wait for the player to select an action in the menu and to return it.
	var data: ActionData = yield(action_menu, "action_selected")
	return data


func _player_select_targets_async(_action: ActionData, opponents: Array) -> Array:
	# TODO get the opponent targetted by telegraphing arrow
	yield(get_tree(), "idle_frame")
	if len(opponents) > 0:
		return [opponents[0]]
	else:
		return []	

func _on_player_turn_finished() -> void:
	# When a player-controlled character finishes their turn
	# and the queue is empty, the player is no longer playing. 
	if _queue_player.empty():
		_is_player_playing = false
	# Otherwise, we pop the array's first value and let the
	# corresponding battler play their turn.
	else:
		_play_turn(_queue_player.pop_front())

