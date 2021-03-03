extends Node2D
class_name Battler

# base + final stats
export var stats: Resource

# optional. If instantiated, let the AI make decisions.
# Otherwise: player-controlled.
# Ally AI (friendly) also possible.
export var ai_scene: PackedScene

# actions the battler can perform, e.g. attack, healing spell.
# Perhaps this is a pointer to our hand of cards.
export var actions: Array

# is this battler friendly or not
export var is_party_member := false

# The turn queue will change this property when another battler is acting.
var time_scale := 1.0 setget set_time_scale
# When this value reaches `100.0`, the battler is ready to take their turn.
var _readiness := 0.0 setget _set_readiness

# pause the battler from a parent node (e.g. for cutscenes)
var is_active: bool = true setget set_is_active


# Emitted when the battler is ready to take a turn.
signal ready_to_act
# Emitted when the battler's `_readiness` changes.
signal readiness_changed(new_value)


func _ready() -> void:
	# stats.reinitialize()
	
	# We connect to the stats' `health_depleted` signal to react to the health reaching `0`.
	stats.connect("health_depleted", self, "_on_BattlerStats_health_depleted")

func _process(delta: float) -> void:
	# Increments the `_readiness`. Note stats.speed isn't defined yet.
	_set_readiness(_readiness + stats.speed * delta * time_scale)

# We will later need to propagate the time scale to status effects, which is why we use a
# setter function.
func set_time_scale(value) -> void:
	time_scale = value

# Setter for the `_readiness` variable. Emits signals when the value changes and when the battler
# is ready to act.
func _set_readiness(value: float) -> void:
	_readiness = value
	emit_signal("readiness_changed", _readiness)

	if _readiness >= 100.0:
		emit_signal("ready_to_act")
		# When the battler is ready to act, we pause the process loop. Doing so prevents _process from triggering another call to this function.
		set_process(false)

func set_is_active(value) -> void:
	is_active = value
	set_process(is_active)

# Returns `true` if the battler is controlled by the player.
func is_player_controlled() -> bool:
	return ai_scene == null

# ------------------------------------------
# Targeting
# ------------------------------------------

# TODO change 
# selection_toggled -> target_toggled
# is_selected -> is_targeted
# is_selectable -> is_targetable

# Emitted when modifying `is_selected`.
# The user interface will react to this for player-controlled battlers.
signal selection_toggled(value)

# If `true`, the battler is selected, which makes it move forward.
var is_selected: bool = false setget set_is_selected
# If `false`, the battler cannot be targeted by any action.
var is_selectable: bool = true setget set_is_selectable


func set_is_selected(value) -> void:
	# This defensive check helps us ensure we don't attempt to change `is_selected` if the battler isn't selectable.
	if value:
		assert(is_selectable)

	is_selected = value
	emit_signal("selection_toggled", is_selected)


func set_is_selectable(value) -> void:
	is_selectable = value
	if not is_selectable:
		set_is_selected(false)


func _on_BattlerStats_health_depleted() -> void:
	# When the health depletes, we turn off processing for this battler.
	set_is_active(false)
	# Then, if it's an opponent, we mark it as unselectable. For party members,
	# you still want to be able to select them to revive them.
	if not is_party_member:
		set_is_selectable(false)
