# Animated life bar.
extends TextureProgress

# Rate of the animation relative to `max_value`. A value of 1.0 means the animation fills the entire
# bar in one second.
export var fill_rate := 1.0

# When this value changes, the bar smoothly animates towards it using a tween.
# See the setter function below for the details.
var target_value := 0.0 setget set_target_value

onready var _tween: Tween = $Tween
onready var _anim_player: AnimationPlayer = $AnimationPlayer


# We initialize the bar through a function because we need to set the `target_value` without
# passing through its setter function.
func setup(health: float, max_health: float) -> void:
	max_value = max_health
	value = health
	target_value = health
	# We animate the bar using the `Tween` node. When the tween completes, we may need to play the
	# "danger" animation.
	_tween.connect("tween_completed", self, "_on_Tween_tween_completed")


func set_target_value(amount: float) -> void:
	# If the `amount` is lower than the current `target_value`, it means the battler lost health.
	if target_value > amount:
		_anim_player.play("damage")

	target_value = amount
	if _tween.is_active():
		_tween.stop_all()

	# We have to calculate the animation's duration every time as we want to have a constant rate or
	# speed at which the bar fills or empties itself.
	var duration := abs(target_value - value) / max_value * fill_rate
	# We then tween from the current `value` to the `target_value` for `duration` seconds.
	_tween.interpolate_property(self, "value", value, target_value, duration, Tween.TRANS_QUAD)
	_tween.start()


# When the tween animation completes, we play the "danger" animation if the battler's health is down
# to 20%.
func _on_Tween_tween_completed(object: Object, key: NodePath) -> void:
	if value < 0.2 * max_value:
		_anim_player.play("danger")
