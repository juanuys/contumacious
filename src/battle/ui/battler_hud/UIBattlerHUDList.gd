# Displays a list of UIBattlerHUDs, one for each battler in the party.
extends VBoxContainer

const UIBattlerHUD: PackedScene = preload("UIBattlerHUD.tscn")

onready var _anim_player: AnimationPlayer = $AnimationPlayer


# Creates a battler HUD for each battler in the party.
func setup(battlers: Array) -> void:
	for battler in battlers:
		var battler_hud: UIBattlerHUD = UIBattlerHUD.instance()
		add_child(battler_hud)
		battler_hud.setup(battler)


# The two functions below respectively play the fade in and fade out animations.
func fade_in() -> void:
	_anim_player.play("fade_in")


func fade_out() -> void:
	_anim_player.play("fade_out")
