# Displays a party member's name, health, and energy.
class_name UIBattlerHUD
extends Position2D

onready var _life_bar: TextureProgress = $UILifeBar
onready var _energy_bar := $UIEnergyBar
onready var _label := $Label


func _ready() -> void:
	Events.connect("combat_action_hovered", self, "_on_Events_combat_action_hovered")
	Events.connect("player_target_selection_done", self, "_on_Events_player_target_selection_done")


# Initializes the health and energy bars using the battler's stats.
func setup(battler: Battler) -> void:
	# We display the battler's name using the Label node.
	_label.text = battler.ui_data.display_name

	# We extract the health and energy from the stats.
	var stats: BattlerStats = battler.stats
	_life_bar.setup(stats.health, stats.max_health)
	_energy_bar.setup(stats.max_energy, stats.energy)

	stats.connect("health_changed", self, "_on_BattlerStats_health_changed")
	stats.connect("energy_changed", self, "_on_BattlerStats_energy_changed")
	
	self.scale = Vector2(0.25, 0.25)


# We control the health in the life bar from this node. All we have to do is update its value.
func _on_BattlerStats_health_changed(_old_value: float, new_value: float) -> void:
	_life_bar.target_value = new_value


# Same for the energy.
func _on_BattlerStats_energy_changed(_old_value: float, new_value: float) -> void:
	_energy_bar.value = new_value


func _on_Events_combat_action_hovered(battler_name: String, energy_cost: int) -> void:
	# When hovering an action, we let each HUD check if they correspond to the battler. We set the
	# label's text to the battler's name in the setup() method so we can use it to find a match.
	if _label.text == battler_name:
		# And we update the selected energy to reflect the action.
		_energy_bar.selected_count = energy_cost


# When the selection is done, we reset the energy bar's `selected_count`
func _on_Events_player_target_selection_done() -> void:
	_energy_bar.selected_count = 0
