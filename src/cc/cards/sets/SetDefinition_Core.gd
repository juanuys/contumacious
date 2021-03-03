# This file contains just card definitions. See also `CardConfig.gd`

extends Reference

const SET = "Demo Set 1"
const CARDS := {
	"Elbow Bump": {
		"Type": CardConfig.CardTypes.card_type_strike,
		"Tags": [""],
		"Requirements": " ",
		"Abilities": "Take that, funny bone!",
		"Cost": 2,
		"Power": 5,
	},
	"Knee Bump": {
		"Type": CardConfig.CardTypes.card_type_strike,
		"Tags": [""],
		"Requirements": " ",
		"Abilities": "Right in the knee",
		"Cost": 3,
		"Power": 8,
	},
}
