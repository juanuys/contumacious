# See README.md
extends Reference

# This fuction returns all the scripts of the specified card name.
#
# if no scripts have been defined, an empty dictionary is returned instead.
func get_scripts(card_name: String) -> Dictionary:
	var scripts := {
		"Elbow Bump": {
			"manual": {
				"hand": [
					{
						"name": "custom_script",
						"subject": "target",
					},
					{
						"name": "move_card_to_container",
						"dest_container": cfc.NMAP.discard,
						"subject": "self",
					},
					{
						"name": "mod_counter",
						"counter_name": "credits",
						"is_cost": true,
						"modification": -1,
					},
				]
			},
		},
		"Knee Knock": {
			"manual": {
				"hand": [
					{
						"name": "custom_script",
						"subject": "target",
					},
					{
						"name": "move_card_to_container",
						"dest_container": cfc.NMAP.discard,
						"subject": "self",
					},
					{
						"name": "mod_counter",
						"counter_name": "credits",
						"is_cost": true,
						"modification": -1,
					},
				]
			},
		},
	}
	# We return only the scripts that match the card name and trigger
	print("getting script: ", card_name)
	return(scripts.get(card_name,{}))
