# Using `class_name` allows us to access the constants from any other file.
class_name Types
extends Reference

# This is the same enum we wrote in the ActionData classes.
enum Elements { NONE, ROCK, PAPER, SCISSORS, BUG }

# Mapping between an element and the element against which it's strong.
const WEAKNESS_MAPPING = {
	# A value of -1 makes the element strong or weak against nothing.
	Elements.NONE: -1,
	# For example, the line below means that scissors is strong against paper.
	Elements.SCISSORS: Elements.PAPER,
	Elements.PAPER: Elements.ROCK,
	Elements.ROCK: Elements.SCISSORS,
	Elements.BUG: -1,
}
