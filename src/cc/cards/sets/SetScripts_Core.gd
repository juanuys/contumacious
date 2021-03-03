# See README.md
extends Reference

# This fuction returns all the scripts of the specified card name.
#
# if no scripts have been defined, an empty dictionary is returned instead.
func get_scripts(card_name: String) -> Dictionary:
	var scripts := {
		"Elbow Bump": {
			"card_moved_to_board": {
				"hand": [
					{
						"name": "custom_script",
						#"subject": "target",
					}
				]
			},
		},
		"Knee Bump": {
			"card_moved_to_board": {
				"hand": [
					{
						"name": "custom_script",
						#"subject": "target",
					}
				]
			},
		},
	}
	# We return only the scripts that match the card name and trigger
	return(scripts.get(card_name,{}))
