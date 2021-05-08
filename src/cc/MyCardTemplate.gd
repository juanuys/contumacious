# A basic card object which includes functionality for handling its own
# placement and focus.
#
# This class is meant to be used as the basis for your card scripting
# Simply make your card scripts extend this class and you'll have all the
# provided scripts available.
# If your card node type is not Area2D, make sure you change the extends type.
class_name MyCard
extends Card

enum Elements { NONE, ROCK, PAPER, SCISSORS, BUG }

var disabled_card = false

# This function handles filling up the card's labels according to its
# card definition dictionary entry.
func setup() -> void:
	.setup()
	
	# also set the face gfx
	var card_art_file: String = "res://assets/cards/" + canonical_name
	for extension in ['.jpg','.jpeg','.png']:
		if ResourceLoader.exists(card_art_file + extension):
			var new_texture = ImageTexture.new();
			var tex = load(card_art_file + extension)
			var image = tex.get_data()
			new_texture.create_from_image(image)
			card_front.art.texture = new_texture
			card_front.art.visible = true

func get_action_data() -> ActionData:
	"""
	Initialises ActionData from card properties.
	The only ActionData impl we have right now is
	AttackActionData.
	"""
	
	var damage_multiplier = 1.0
	var hit_chance = 100.0
	var status_effect = null
	var energy_cost = int(properties["Cost"])
	var damage = int(properties["Power"])
	var element = Elements.NONE
	var is_targeting_self = false
	var is_targeting_all = false
	var readiness_saved = 0.0
	var label = properties["Name"]
	
	
	var action_data: ActionData = AttackActionData.new(
		damage_multiplier,
		hit_chance,
		status_effect,
		energy_cost,
		damage,
		element,
		is_targeting_self,
		is_targeting_all,
		readiness_saved,
		label
		)
	
	return action_data

# A signal for whenever the player clicks on a card
func _on_Card_gui_input(event) -> void:
	if disabled_card:
		return

	# this is commented as we want to disable drag for now
	# ._on_Card_gui_input(event)
	
	if event is InputEventMouseButton:
		if event.is_pressed() and event.get_button_index() == 1:
			targeting_arrow.initiate_targeting()
		elif not event.is_pressed() and event.get_button_index() == 1:
			targeting_arrow.complete_targeting()
			
			if ((check_play_costs() != CFConst.CostsState.IMPOSSIBLE
					and get_state_exec() == "hand")
					or get_state_exec() == "board"):
				execute_scripts()



# customisable hooks

# This function can be overriden by any class extending Card, in order to provide
# a way of running scripts which might change where a card moves
#
# This method will be called before the card moves anywhere,
# but before board_placement is evaluted. This allows a card which has been
# setup to not allow moves to the board,
# (which would normally send it back to its origin container)
# to instead be redirected to a pile.
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func common_pre_move_scripts(new_host: Node, old_host: Node, move_tags: Array) -> Node:
	return(new_host)

# This function can be overriden by any class extending Card, in order to provide
# a way of running scripts for a whole class of cards, based on where the card moves.
#
# This method will be called after the card moves anywhere, to a different
# container, or the same. new_host is where it moved to, and old_host
# is where it moved from. They can be the same, such as when a card changes
# places on the table.
# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func common_post_move_scripts(new_host: Node, old_host: Node, move_tags: Array) -> void:
	pass


# This function can be overriden by any class extending Card, in order to provide
# a way of running scripts for a whole class of cards, based on what the trigger was
# before all normal scripts have been executed
#
# This is useful for example, for paying the costs of one-use cards before executing them
# warning-ignore:unused_argument
func common_pre_execution_scripts(trigger: String) -> void:
	pass


# This function can be overriden by any class extending Card, in order to provide
# a way of running scripts for a whole class of cards, based on what the trigger was
# after all normal scripts have been executed
#
# This is useful for example, for discarding one-use cards after playing them
# warning-ignore:unused_argument
func common_post_execution_scripts(trigger: String) -> void:
	pass



func _on_Card_card_moved_to_hand(card, trigger, details):
	$SFX.play_sound()


func _on_Card_card_moved_to_pile(card, trigger, details):
	$SFX.play_sound()
