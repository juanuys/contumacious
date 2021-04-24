# Handles drawing a Card's targeting arrow
# and specifying the final target
class_name MyTargetingArrow
extends TargetingArrow


# Will generate a targeting arrow on the card which will follow the mouse cursor.
# The top card hovered over by the mouse cursor will be highlighted
# and will become the target when complete_targeting() is called
func initiate_targeting() -> void:
	is_targeting = true
	$ArrowHead.visible = true
	$ArrowHead/Area2D.monitoring = true
	emit_signal("initiated_targeting")


# Will end the targeting process.
#
# The top card which is hovered (if any) will become the target and inserted
# into the target_card property for future use.
func complete_targeting() -> void:
	if len(_potential_targets) and is_targeting:
		var tc = _potential_targets.back()
		# We don't want to emit a signal, if the card is a dummy viewport card
		# or we already selected a target during dry-run
		if owner_object.get_parent() != null \
				and owner_object.get_parent().name != "Viewport":
			# We make the targeted card also emit a targeting signal for automation
			tc.emit_signal("card_targeted", tc, "card_targeted",
					{"targeting_source": owner_object})
		target_object = tc
	emit_signal("target_selected",target_object)
	is_targeting = false
	clear_points()
	$ArrowHead.visible = false
	$ArrowHead/Area2D.monitoring = false


# Triggers when a targetting arrow hovers over another card while being dragged
#
# It takes care to highlight potential cards which can serve as targets.
func _on_ArrowHead_area_entered(target: Area2D) -> void:
	if target:
		var is_ignore := target.get_parent().name in ["Hand", "ArrowHead"]
		if is_ignore:
			return
			
		var is_battler := target.get_parent().get_parent().name == "BattlerAnim"
		var is_card := target.get_class() == 'Card'
		
		# first and foremost, target a battler
		if is_battler:
			_potential_targets.append(target)
		elif target.get_class() == 'Card' and not target in _potential_targets:
			_potential_targets.append(target)
			if 'highlight' in owner_object:
				owner_object.highlight.highlight_potential_card(
						CFConst.TARGET_HOVER_COLOUR, _potential_targets)


# Triggers when a targetting arrow stops hovering over a card
#
# It clears potential highlights and adjusts potential cards as targets
func _on_ArrowHead_area_exited(target: Area2D) -> void:
	if target:
		# var is_battler := target.get_parent().get_parent().name == "BattlerAnim"
		# var is_card := target.get_class() == 'Card'
			
		if target in _potential_targets:
			# We remove the card we stopped hovering from the _potential_targets
			_potential_targets.erase(target)
			# And we explicitly hide its cards focus since we don't care about it anymore
			if 'highlight' in target:
				target.highlight.set_highlight(false)
			# Finally, we make sure we highlight any other cards we're still hovering
			if not _potential_targets.empty() and 'highlight' in owner_object:
				owner_object.highlight.highlight_potential_card(
					CFConst.TARGET_HOVER_COLOUR,
					_potential_targets)
