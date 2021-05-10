# This file contains just card definitions. See also `CardConfig.gd`

extends Reference

const SET = "Demo Set 1"
const CARDS := {
	"Elbow Bump": {
		"Type": CardConfig.CardTypes.card_type_strike,
		"Tags": ["‎"],
		"Requirements": "‎",
		"Abilities": "Bump your foe's elbow off the armrest",
		"Cost": 2,
		"Power": 5,
	},
	"Knee Knock": {
		"Type": CardConfig.CardTypes.card_type_strike,
		"Tags": ["‎"],
		"Requirements": "‎",
		"Abilities": "Reclaim your leg room, and then some",
		"Cost": 3,
		"Power": 8,
	},
}
