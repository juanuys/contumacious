# A basic card object which includes functionality for handling its own
# placement and focus.
#
# This class is meant to be used as the basis for your card scripting
# Simply make your card scripts extend this class and you'll have all the
# provided scripts available.
# If your card node type is not Area2D, make sure you change the extends type.
class_name MyCard
extends Card

# This function handles filling up the card's labels according to its
# card definition dictionary entry.
func setup() -> void:
	.setup()
	
	# also set the face gfx
	var card_art_file: String = "res://assets/cards/" + canonical_name
	for extension in ['.jpg','.jpeg','.png']:
		if ResourceLoader.exists(card_art_file + extension):
			var new_texture = ImageTexture.new();
			var tex = load(card_art_file + extension)
			var image = tex.get_data()
			new_texture.create_from_image(image)
			card_front.art.texture = new_texture
			card_front.art.visible = true

# A signal for whenever the player clicks on a card
func _on_Card_gui_input(event) -> void:
	# this is commented as we want to disable drag for now
	# ._on_Card_gui_input(event)
	
	if event is InputEventMouseButton:
		if event.is_pressed() and event.get_button_index() == 1:
			targeting_arrow.initiate_targeting()
		elif not event.is_pressed() and event.get_button_index() == 1:
			targeting_arrow.complete_targeting()
			
			if ((check_play_costs() != CFConst.CostsState.IMPOSSIBLE
					and get_state_exec() == "hand")
					or get_state_exec() == "board"):
				execute_scripts()

