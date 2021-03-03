# This class contains very custom scripts definitionsa for objects that need them
#
# The definition happens via object name
class_name CustomScripts
extends Reference

var costs_dry_run := false

func _init(dry_run_req) -> void:
	costs_dry_run = dry_run_req
# This fuction executes custom scripts
#
# It relies on the definition of each script being based the object's name
# Therefore the only thing we need, is the object itself to grab its name
# And to have a self-reference in case it affects itself
#
# You can pass a predefined subject, but it's optional.
func custom_script(script: ScriptObject) -> void:
	var card: Card = script.owner_card
	var subjects: Array = script.subjects
	# I don't like the extra indent caused by this if, 
	# But not all object will be Card
	# So I can't be certain the "card_name" var will exist
	print_debug("custom script?")
	match script.owner_card.card_name:
		"Elbow Bump":
			# No demo cost-based custom scripts
			print_debug("ELBOW CUMP")
			if not costs_dry_run:
				print_debug("ELBOW CUMP!")
		"Knee Bump":
			print_debug("KNEE CUMP")
			if not costs_dry_run:
				print_debug("KNEE CUMP!")

func custom_alterants(script: ScriptObject) -> int:
	var alteration := 0
	return(alteration)
