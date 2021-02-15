# This file contains just card definitions. See also `CardConfig.gd`

extends Reference

const SET = "Demo Set 1"
const CARDS := {
	"Elbow Bump": {
		"Type": "Strike",
		"labels": {
			"Tags": [""],
			"Requirements": "",
			"Abilities": "Take that, funny bone!",
			"Cost": 2,
			"Power": 5,
		},
		"sprites": {
			"Face": "res://assets/cards/elbow-bump3.png",
		},
	},
	"Knee Bump": {
		"Type": "Strike",
		"labels": {
			"Tags": [""],
			"Requirements": "",
			"Abilities": "Right in the knee",
			"Cost": 2,
			"Power": 5,
		},
		"sprites": {
			"Face": "res://assets/cards/knee-bump.png",
		},
	},
}
