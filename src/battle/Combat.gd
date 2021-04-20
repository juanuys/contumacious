extends Node2D

# We're going to get the battlers from the `ActiveTurnQueue` node.
onready var active_turn_queue := $ActiveTurnQueue
onready var ui_turn_bar := $UI/UITurnBar
onready var ui_battler_hud_list := $UI/UIBattlerHUDList

# We set up the turn bar when the node is ready, which ensures all its children also are ready.
func _ready() -> void:
	var battlers: Array = active_turn_queue.battlers
	
	# We need a HUD only for party members. So we filter them here.
	var in_party := []
	for battler in battlers:
		if battler.is_party_member:
			in_party.append(battler)
			
	ui_turn_bar.setup(active_turn_queue.battlers)
	ui_battler_hud_list.setup(in_party)

