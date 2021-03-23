class_name AggressiveBattlerAI
extends BattlerAI


func _choose_action(info: Dictionary) -> ActionData:
	# aggressive AI always pick the strongest action.
	print("AggressiveBattlerAI.choose ", info)
	return info.strongest_action


func _choose_targets(_action: ActionData, info: Dictionary) -> Array:
	# arrays of targets to support targeting multiple targets.
	# aggresive AI always picks on the weakest targets
	return [info.weakest_target]
