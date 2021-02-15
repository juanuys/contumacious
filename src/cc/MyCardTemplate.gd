# A basic card object which includes functionality for handling its own
# placement and focus.
#
# This class is meant to be used as the basis for your card scripting
# Simply make your card scripts extend this class and you'll have all the
# provided scripts available.
# If your card node type is not Area2D, make sure you change the extends type.
class_name MyCard
extends Card



# This function can be overriden by any class extending Card, in order to provide
# a way of checking if a card can be played before dragging it out of the hand.
#
# This method will be called while the card is being focused by the player
# If it returns true, the card will be highlighted as normal and the player
# will be able to drag it out of the hand
#
# If it returns false, the card will be highlighted with a red tint, and the
# player will not be able to drag it out of the hand.
func check_play_costs() -> Color:
	return(CFConst.CostsState.OK)


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
func common_pre_move_scripts(new_host: Node, old_host: Node, scripted_move: bool) -> Node:
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
func common_post_move_scripts(new_host: Node, old_host: Node, scripted_move: bool) -> void:
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

