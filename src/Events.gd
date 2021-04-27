# Event bus for distant nodes to communicate using signals.
# This is intended for cases where connecting the nodes directly creates more coupling
# or substantially increases code complexity.
extends Node

# Emitted when the player hovers a card or action button, to preview the corresponding action's energy cost.
# We will use the display name to identify the HUD that corresponds to a given battler.
signal combat_action_hovered(display_name, energy_cost)
# Emitted during a player's turn, when they chose an action and validated their target.
signal player_target_selection_done

# Emitted from CustomScripts and yielded on in ActiveTurnQueue
signal action_selected(action_data)
