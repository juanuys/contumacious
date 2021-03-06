# This class contains very custom scripts definitionsa for objects that need them
#
# The definition happens via object name
class_name CustomScripts
extends Reference

var costs_dry_run := false

func _init(_dry_run) -> void:
	costs_dry_run = _dry_run


func _get_battler(subject):
	"""
	This debug outputs:
		
		subject: Area2D
		parent: Pivot
		+ parent: BattlerAnim
		+ + parent: BattlerAntagonist
		+ + + parent: ActiveTurnQueue
		+ + + + parent: Combat

	"""
	var debug = false
	if debug:
		print("""
		subject: %s
		parent: %s
		+ parent: %s
		+ + parent: %s
		+ + + parent: %s
		+ + + + parent: %s
		""" % [
			subject.name,
			subject.get_parent().name,
			subject.get_parent().get_parent().name,
			subject.get_parent().get_parent().get_parent().name,
			subject.get_parent().get_parent().get_parent().get_parent().name,
			subject.get_parent().get_parent().get_parent().get_parent().get_parent().name,
		])
	return subject.get_parent().get_parent().get_parent()


# This fuction executes custom scripts
#
# It relies on the definition of each script being based the object's name
# Therefore the only thing we need, is the object itself to grab its name
# And to have a self-reference in case it affects itself
#
# You can pass a predefined subject, but it's optional.
func custom_script(script: ScriptObject) -> void:
	Events.emit_signal("player_target_selection_done")
	match script.owner.canonical_name:
		"Elbow Bump":
			_play_card(script)
		"Knee Knock":
			_play_card(script)
		"Newspaper":
			_play_card(script)
		_:
			print("XXXXXXXXX")
			print("card not matched: %s" % script.owner.canonical_name)
			print("XXXXXXXXX")


func _play_card(script: ScriptObject):
	var subjects: Array = script.subjects
	if len(subjects) == 0:
		script.is_cancelled = true
		return
	
	if not costs_dry_run:
		var card: Card = script.owner
		print("Playing card: %s" % card.canonical_name)
		
		var action_data = card.get_action_data()
		
		# TODO enforce one subject for now?
		for subject in subjects:
			var battler = _get_battler(subject)
			if battler.name == "BattlerProtagonist":
				script.is_cancelled = true
				return
			
			action_data.maybe_target = battler
		
		Events.emit_signal("action_selected", action_data)

# warning-ignore:unused_argument
func custom_alterants(script: ScriptObject) -> int:
	var alteration := 0
	return(alteration)
