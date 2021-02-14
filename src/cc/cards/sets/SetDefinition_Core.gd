# This file contains just card definitions. See also `CardConfig.gd`

extends Reference

const SET = "Demo Set 1"
const CARDS := {
	"Elbow Bump": {
		"Type": "Strike",
		"Tags": ["Tag 1","Tag 2"],
		"Requirements": "",
		"Abilities": "Knocks your opponent's arm off the armrest",
		"Cost": 2,
		"Power": 5,
	},
	"Knee Bump": {
		"Type": "Strike",
		"Tags": ["Tag 1","Tag 2"],
		"Requirements": "",
		"Abilities": "Sends a pang of pain through your opponent's leg",
		"Cost": 2,
		"Power": 5,
	},
}
