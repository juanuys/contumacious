class_name ActionData
extends Resource

# We will define this enum several times in our codebase.
# Having it in the file allows us to use it as an export hint and to have a
# drop-down menu in the inspector. See `element` below.
enum Elements { NONE, ROCK, PAPER, SCISSORS, BUG }

# The following two properties are for the user interface.
# We will use them to represent the action in menus.
export var icon: Texture
export var label := "Base combat action"

# Amount of energy the action costs to perform.
export var energy_cost := 0
export var damage := 1.0
# Elemental type of the action. We'll use it later to add bonus damage if
# the action's target is weak to the element.
export (Elements) var element := Elements.NONE

# The following properties help us filter potential targets on a battler's turn.
export var is_targeting_self := false
export var is_targeting_all := false

# The amount of readiness left to the battler after acting.
# You can use it to design weak attacks that allow you to take turn fast.
export var readiness_saved := 0.0

# HACK: a target is set here if the action data is 
# constructed from a card.
# The battler would be known at the moment we play a card, as
# the player will be telegraphing with an arrow.
var maybe_target = null

func _init(
	p_energy_cost = 0,
	p_damage = 1.0,
	p_element = Elements.NONE,
	p_is_targeting_self = false,
	p_is_targeting_all = false,
	p_readiness_saved = 0.0,
	p_label = "Base combat action"
	):
	energy_cost = p_energy_cost
	damage = p_damage
	element = p_element
	is_targeting_self = p_is_targeting_self
	is_targeting_all = p_is_targeting_all
	readiness_saved = p_readiness_saved
	label = p_label


# Returns `true` if the `battler` has enough energy to use the action.
func can_be_used_by(battler) -> bool:
	return energy_cost <= battler.stats.energy
