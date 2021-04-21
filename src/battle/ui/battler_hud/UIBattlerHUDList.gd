# Displays a list of UIBattlerHUDs, one for each battler.
extends Node2D

const UIBattlerHUD: PackedScene = preload("UIBattlerHUD.tscn")

onready var _anim_player: AnimationPlayer = $AnimationPlayer


# Creates a battler HUD for each battler.
func setup(battlers: Array) -> void:
	for battler in battlers:
		var battler_hud: UIBattlerHUD = UIBattlerHUD.instance()
		add_child(battler_hud)
		battler_hud.setup(battler)
		battler_hud.global_position = battler.battler_anim.get_bottom_anchor_global_position()


# The two functions below respectively play the fade in and fade out animations.
func fade_in() -> void:
	_anim_player.play("fade_in")


func fade_out() -> void:
	_anim_player.play("fade_out")
