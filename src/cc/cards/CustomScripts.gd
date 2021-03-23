# This class contains very custom scripts definitionsa for objects that need them
#
# The definition happens via object name
class_name CustomScripts
extends Reference

var costs_dry_run := false

func _init(_dry_run) -> void:
	costs_dry_run = _dry_run


func _get_battler(subject):
	return subject.get_parent().get_parent().get_parent()


# This fuction executes custom scripts
#
# It relies on the definition of each script being based the object's name
# Therefore the only thing we need, is the object itself to grab its name
# And to have a self-reference in case it affects itself
#
# You can pass a predefined subject, but it's optional.
func custom_script(script: ScriptObject) -> void:
	var card: Card = script.owner
	var subjects: Array = script.subjects
	match script.owner.canonical_name:
		"Elbow Bump":
			if not costs_dry_run:
				print("CARD SCRIPT elbow bump")
				for subject in subjects:
					var battler = _get_battler(subject)
					print("subject: %s" % battler)
					var hit = Hit.new(50)
					battler.take_hit(hit)
		"Knee Bump":
			if not costs_dry_run:
				print("CARD SCRIPT knee bump")
				for subject in subjects:
					var battler = _get_battler(subject)
					print("subject: %s" % battler)
					var hit = Hit.new(20)
					battler.take_hit(hit)

# warning-ignore:unused_argument
func custom_alterants(script: ScriptObject) -> int:
	var alteration := 0
	return(alteration)
