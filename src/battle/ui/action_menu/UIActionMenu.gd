# Menu displaying lists of actions the player can select.
class_name UIActionMenu
extends Control

# Emitted when the player selected an action.
signal action_selected

# We preload our UIActionList scene to instantiate it from the code.
# The file UIActionList.tscn must be in the same directory for this to work.
const UIActionList := preload("UIActionList.tscn")


func _ready() -> void:
	hide()


# This function is a bit like the previous nodes' `setup()`, but I decided to call it open
# instead because it feels more natural for a menu. Also, it toggles the node's visibility on.
func open(battler: Battler) -> void:
	var list = UIActionList.instance()
	add_child(list)
	# We listen to the UIActionList's action_selected signal to automatically close the menu and
	# forward the signal when the player selects an action.
	list.connect("action_selected", self, "_on_UIActionsList_action_selected")
	list.setup(battler)
	show()
	# Calling the list's `focus()` method allows the first button to grab focus.
	list.focus()


# We free the menu upon closing it.
func close() -> void:
	hide()
	queue_free()


func _on_UIActionsList_action_selected(action: ActionData) -> void:
	emit_signal("action_selected", action)
	close()
