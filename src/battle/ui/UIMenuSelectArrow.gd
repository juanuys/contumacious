# Arrow to select actions in a [UIActionList].
extends Position2D

onready var _tween: Tween = $Tween


# The arrow needs to move indepedently from its parent.
func _init() -> void:
	set_as_toplevel(true)


# The UIActionList can use this function to move the arrow.
func move_to(target: Vector2) -> void:
	# If it's already moving, we stop and re-create the tween.
	if _tween.is_active():
		_tween.stop(self, "position")
	
	# To move the arrow, we tween its position, which is global, for 0.1 seconds.
	# This short duration makes the menu feel responsive.
	_tween.interpolate_property(
		self, "position", position, target, 0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	_tween.start()
