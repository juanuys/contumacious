# Bar representing energy points. Each point is an instance of UIEnergyPoint.
extends HBoxContainer

# We preload the energy point to instantiate it in `setup()`
# Once again, you need `UIEnergyPoint.tscn` to be in the same directory for the path to work.
const UIEnergyPoint: PackedScene = preload("UIEnergyPoint.tscn")

# The following properties are in the same logic as Godot's built-in progress bar, which extends the
# `Range` class. While we could also extend `Range`, it works with floating-point values, while our
# energy is integer-based, and it would have more unnecessary features.
var max_value := 0

var value := 0 setget set_value
var selected_count := 0 setget set_selected_count


# The setup function creates `max_energy` instances of the energy point scene.
func setup(max_energy: int, energy: int) -> void:
	max_value = max_energy
	value = energy
	# This is a shorthand for `range(max_value)`.
	for i in max_value:
		var energy_point: TextureRect = UIEnergyPoint.instance()
		# The points will be children of the bar, allowing us to manipulate them with the
		# `get_child()` function.
		add_child(energy_point)


func set_value(amount: int) -> void:
	var old_value := value
	value = int(clamp(amount, 0.0, max_value))
	# The code below makes points appear and disappear when the value changes. As each point is a separate object, we need to loop over them and call the corresponding function on each instance.
	if value > old_value:
		# If we have more points, we need to play the "appear" animation on the added points only.
		# That's why we generate a range of indices from `old_value` to `value`.
		for i in range(old_value, value):
			get_child(i).appear()
	else:
		# If we lost points, we generate a range of indices going down, using `step`, the function's third argument.
		for i in range(old_value, value, -1):
			get_child(i - 1).disappear()


# This function follows the logic of `set_value()` but plays the "select" and "deselect" animations
# on the points instead of "appear" and "disappear". We will use it in the next lesson to preview
# the energy cost of actions in the player's turn.
func set_selected_count(amount: int) -> void:
	var old_value := selected_count
	selected_count = int(clamp(amount, 0.0, max_value))
	if selected_count > old_value:
		for i in range(old_value, selected_count):
			get_child(i).select()
	else:
		for i in range(old_value, selected_count, -1):
			get_child(i - 1).deselect()
