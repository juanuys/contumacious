# ScriptEngine

## "manual"

From: https://github.com/db0/godot-card-game-framework/wiki/ScriptDefinitions

"manual" is default (when a card is double-clicked)

var known_card_signals := [
    "card_rotated",
    "card_flipped",
    "card_viewed",
    "card_moved_to_board",
    "card_moved_to_pile",
    "card_moved_to_hand",
    "card_token_modified",
    "card_attached",
    "card_unattached",
    "card_targeted",
    "card_properties_modified",
]

Can be extended:
- alterants

# Used in place of a trigger name (e.g. 'manual'). This key allows the card to be marked as
# an "Alterant". I.e. a card which will modify the values of other scripts or
# effects.

- competition_ended (fragment forge)

## "board"

board, hand, pile, or NONE

# Targeting signals

