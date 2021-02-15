extends CardFront
# see StrikeFront, etc

onready var card_face = $Face

func _ready() -> void:
	text_expansion_multiplier = {
		"Name": 1,
		"Tags": 1,
		"Cost": 1,
		"Power": 1,
	}
	compensation_label = "Abilities"
	_card_text = $Margin/CardText
	card_labels["Name"] = $Margin/CardText/Name
	card_labels["Type"] = $Margin/CardText/Type
	card_labels["Tags"] = $Margin/CardText/Tags
	card_labels["Requirements"] = $Margin/CardText/Requirements
	card_labels["Abilities"] = $Margin/CardText/Abilities
	card_labels["Cost"] = $Margin/CardText/HB/Cost
	card_labels["Power"] = $Margin/CardText/HB/Power


func load_sprites(sprites: Dictionary):
	print("loading sprites...")
	var face_sprite: String = sprites["Face"]
	card_face.set_texture(load(face_sprite))

# Set a label node's text.
# As the string becomes longer, the font size becomes smaller
func set_label_text(node: Label, value):
	_capture_original_font_size(node)
	# We do not want some fields, like the name, to be too small.
	# see CardConfig.TEXT_EXPANSION_MULTIPLIER documentation
	var allowed_expansion = text_expansion_multiplier.get(node.name,1)
	var adjust_size : float
	# There is always one specified label that compensates for other nodes
	# increasing or decreasing their y-rect.
	if node.name in compensation_label:
		adjust_size = _rect_adjustment
	var label_size = node.rect_min_size
	var label_font : Font = node.get("custom_fonts/font").duplicate()
	# We always start shrinking the size, starting from the original size.
	label_font.size = original_font_sizes[node]
	var line_height = label_font.get_height()
	# line_spacing should be calculated into rect_size
	var line_spacing = node.get("custom_constants/line_spacing")
	if not line_spacing:
		line_spacing = 3
	# This calculates the amount of vertical pixels the text would take
	# once it was word-wrapped.
	var label_rect_y = label_font.get_wordwrap_string_size(
			value, label_size.x).y \
			/ line_height \
			* (line_height + line_spacing) \
			- line_spacing
	# If the y-size of the wordwrapped text would be bigger than the current
	# available y-size foir this label, we reduce the text, until we
	# it's small enough to stay within the boundaries
	while label_rect_y > label_size.y * allowed_expansion - adjust_size:
		label_font.size = label_font.size - 1
		if label_font.size < 3:
			label_font.size = 2
			break
		label_rect_y = label_font.get_wordwrap_string_size(
				value,label_size.x).y \
				/ line_height \
				* (line_height + line_spacing) \
				- line_spacing
	# If we allowed the card to expand its initial rect_size.y
	# we need to compensate somewhere by reducing another label's size.
	# We store the amount we increased in size from the
	# initial amount,m for this purpose.
	if label_rect_y > label_size.y:
		_rect_adjustment += label_rect_y - label_size.y
	if value == "":
		_rect_adjustment -= node.rect_size.y
		# opyate: I commented the following, because it messes with the layout.
		# opyate: Empty nodes are not just spacer nodes.
#		node.visible = false
	node.set("custom_fonts/font", label_font)
	node.rect_min_size = label_size
	node.text = value
	# After any adjustmen of labels, we make sure the compensation_label font size
	# is adjusted again, if needed, to avoid exceeding the card borders.
	if not node.name in compensation_label and _rect_adjustment != 0.0:
		set_label_text(card_labels[compensation_label], card_labels[compensation_label].text)
