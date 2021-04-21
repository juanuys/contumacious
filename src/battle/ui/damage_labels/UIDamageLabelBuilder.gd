# Spawns labels that display damage, healing, or missed hits.
class_name UIDamageLabelBuilder
extends Node2D

# We preload the labels.
export var damage_label_scene: PackedScene = preload("UIDamageLabel.tscn")
export var miss_label_scene: PackedScene = preload("UIMissedLabel.tscn")


# In setup(), we connect to the Battler's `damage_taken` and `hit_missed` signals to instantiate the appropriate labels.
func setup(battlers: Array) -> void:
	for battler in battlers:
		battler.connect("damage_taken", self, "_on_Battler_damage_taken", [battler])
		battler.connect("hit_missed", self, "_on_Battler_hit_missed", [battler])
		

# When a battler takes damage, we instantiate a damage label.
func _on_Battler_damage_taken(amount: int, target: Battler) -> void:
	var label: UIDamageLabel = damage_label_scene.instance()
	# The setup() function takes care of changing the color, setting the text and placing it.
	label.setup(UIDamageLabel.Types.DAMAGE, target.battler_anim.get_top_anchor_global_position(), amount)
	# Adding the label as a child causes the animation to start.
	add_child(label)


func _on_Battler_hit_missed(target: Battler) -> void:
	var label = miss_label_scene.instance()
	add_child(label)
	# The miss label doesn't have a setup() function so we set its position by hand.
	label.global_position = target.battler_anim.get_top_anchor_global_position()
