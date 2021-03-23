# Handles drawing a Card's targeting arrow
# and specifying the final target
class_name MyTargetingArrow
extends TargetingArrow

# We use this to track multiple battlers
# when our owner_card is about to target them.
# (like _potential_cards)
var _potential_battlers := []

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
	if is_targeting:
		if len(_potential_battlers):
			var tc = _potential_battlers.back()
			print("emitting ", tc)
			emit_signal("target_selected", tc)
		elif len(_potential_cards):
			var tc = _potential_cards.back()
			target_card = tc
			# We don't want to emit a signal, if the card is a dummy viewport card
			# or we already selected a target during dry-run
			if owner_card.get_parent() != null \
					and owner_card.get_parent().name != "Viewport":
				# We make the targeted card also emit a targeting signal for automation
				tc.emit_signal("card_targeted", tc, "card_targeted",
						{"targeting_source": owner_card})
			target_card = tc
			emit_signal("target_selected",target_card)
			
	is_targeting = false
	clear_points()
	$ArrowHead.visible = false
	$ArrowHead/Area2D.monitoring = false


# Triggers when a targetting arrow hovers over another card while being dragged
#
# It takes care to highlight potential cards which can serve as targets.
func _on_ArrowHead_area_entered(target: Area2D) -> void:
	if target:
		if target.get_parent().name in ["Hand", "ArrowHead"]:
			return
		if target.get_parent().get_parent().name == "BattlerAnim":
			_potential_battlers.append(target)
		elif not target in _potential_cards:
			_potential_cards.append(target)
			owner_card.highlight.highlight_potential_card(CFConst.TARGET_HOVER_COLOUR,
					_potential_cards)


# Triggers when a targetting arrow stops hovering over a card
#
# It clears potential highlights and adjusts potential cards as targets
func _on_ArrowHead_area_exited(target: Area2D) -> void:
	if target:
		#if target.get_parent().get_parent().name == "BattlerAnim":
		if target in _potential_battlers:
			_potential_battlers.erase(target)
		elif target in _potential_cards:
			# We remove the card we stopped hovering from the _potential_cards
			_potential_cards.erase(target)
			# And we explicitly hide its cards focus since we don't care about it anymore
			target.highlight.set_highlight(false)
			# Finally, we make sure we highlight any other cards we're still hovering
			if not _potential_cards.empty():
				owner_card.highlight.highlight_potential_card(
					CFConst.TARGET_HOVER_COLOUR,
					_potential_cards)
