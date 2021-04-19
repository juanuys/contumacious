extends Node2D

# We're going to get the battlers from the `ActiveTurnQueue` node.
onready var active_turn_queue := $ActiveTurnQueue
onready var ui_turn_bar := $UI/UITurnBar


# We set up the turn bar when the node is ready, which ensures all its children also are ready.
func _ready() -> void:
	var battlers: Array = active_turn_queue.battlers
	ui_turn_bar.setup(active_turn_queue.battlers)
