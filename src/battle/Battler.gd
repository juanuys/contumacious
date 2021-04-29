extends Node2D
class_name Battler

# base + final stats
export var stats: Resource

# optional. If instantiated, let the AI make decisions.
# Otherwise: player-controlled.
# Ally AI (friendly) also possible.
export var ai_scene: PackedScene

# actions the battler can perform, e.g. attack, healing spell.
# Perhaps this is a pointer to our hand of cards.
export var actions: Array

# is this battler friendly or not
export var is_party_member := false

# The turn queue will change this property when another battler is acting.
var time_scale := 1.0 setget set_time_scale
# When this value reaches `100.0`, the battler is ready to take their turn.
var _readiness := 0.0 setget _set_readiness

# pause the battler from a parent node (e.g. for cutscenes)
var is_active: bool = true setget set_is_active

# Emitted when the battler is ready to take a turn.
signal ready_to_act
# Emitted when the battler's `_readiness` changes.
signal readiness_changed(new_value)

# Emitted when taking damage.
# Used to display the number of damage taken
signal damage_taken(amount)
# Emitted when a received hit missed.
# Used to display a "miss" label on the screen.
signal hit_missed

# Emitted when the battler finished their action and arrived
# back at their rest position.
signal action_finished

# Emitted when an animation from `battler_anim` finished playing.
signal animation_finished(anim_name)

onready var battler_anim: BattlerAnim = $BattlerAnim
onready var _status_effect_container: StatusEffectContainer = $StatusEffectContainer

export var ui_data: Resource

onready var my_sprite := $BattlerAnim/Pivot/Area2D/Sprite

func _ready() -> void:
	# Resources are shared in memory so if you have two monsters of 
	# the same type on the battlefield, they’re going to reference
	# the same BattlerStats instance and share health. If we don’t
	# duplicate the stats resources, when either takes damage, it’s
	# the same value that goes down.
	assert(stats is BattlerStats)
	stats = stats.duplicate()

	# We connect to the stats' `health_depleted` signal to react to the health reaching `0`.
	stats.connect("health_depleted", self, "_on_BattlerStats_health_depleted")
	
	# set sprite and other properties according to Resource
	my_sprite.texture = ui_data.texture
	my_sprite.flip_h = ui_data.flip


func _process(delta: float) -> void:
	# Increments the `_readiness`.
	_set_readiness(_readiness + stats.speed * delta * time_scale)


# propagate the time scale to status effects
func set_time_scale(value) -> void:
	time_scale = value
	_status_effect_container.time_scale = time_scale


# Setter for the `_readiness` variable.
# Emits signals when the value changes and when the battler is ready to act.
func _set_readiness(value: float) -> void:
	_readiness = value
	emit_signal("readiness_changed", _readiness)

	if _readiness >= 100.0:
		emit_signal("ready_to_act")
		# When the battler is ready to act, we pause the process loop. Doing so prevents _process from triggering another call to this function.
		set_process(false)


# propagate the active bool to status effects
func set_is_active(value) -> void:
	is_active = value
	set_process(is_active)
	_status_effect_container.is_active = value


# Returns `true` if the battler is controlled by the player.
func is_player_controlled() -> bool:
	return ai_scene == null


# This function applies the status effect to the battler.
# Effect is of type `StatusEffect`.
func _apply_status_effect(effect) -> void:
	_status_effect_container.add(effect)

# ------------------------------------------
# Targeting
# ------------------------------------------

# TODO change 
# selection_toggled -> target_toggled
# is_selected -> is_targeted
# is_selectable -> is_targetable

# Emitted when modifying `is_selected`.
# The user interface will react to this for player-controlled battlers.
signal selection_toggled(value)

# If `true`, the battler is selected, which makes it move forward.
var is_selected: bool = false setget set_is_selected
# If `false`, the battler cannot be targeted by any action.
var is_selectable: bool = true setget set_is_selectable


func set_is_selected(value) -> void:
	# This defensive check helps us ensure we don't attempt to change `is_selected` if the battler isn't selectable.
	if value:
		assert(is_selectable)

	is_selected = value
	if is_selected:
		battler_anim.move_forward()
	emit_signal("selection_toggled", is_selected)


func set_is_selectable(value) -> void:
	is_selectable = value
	if not is_selectable:
		set_is_selected(false)


func _on_BattlerStats_health_depleted() -> void:
	# When the health depletes, we turn off processing for this battler.
	set_is_active(false)
	# Then, if it's an opponent, we mark it as unselectable. For party members,
	# you still want to be able to select them to revive them.
	if not is_party_member:
		set_is_selectable(false)
		# We only play the animation for monsters as
		# it makes them disappear from the battlefield.
		battler_anim.queue_animation("die")


# Applies a hit object to the battler, dealing damage or status effects.
func take_hit(hit: Hit) -> void:
	# We encapsulated the hit chance in the hit. The hit object tells us if we should take damage.
	if hit.does_hit():
		_take_damage(hit.damage)
		emit_signal("damage_taken", hit.damage)
		# If the hit comes with an effect, we apply it to the battler.
		if hit.effect:
			_apply_status_effect(hit.effect)
	else:
		emit_signal("hit_missed")


# Applies damage to the battler's stats.
# also trigger a damage animation.
func _take_damage(amount: int) -> void:
	stats.health -= amount
	print("%s took %s damage. Health is now %s." % [name, amount, stats.health])
	if stats.health > 0:
		battler_anim.play("take_damage")


# We can't specify the `action`'s type hint here due to cyclic
# dependency errors in Godot 3.2.
# But it should be of type `Action` or derived, like `AttackAction`.
func act(action) -> void:
	# If the action costs energy, we subtract it.
	stats.energy -= action.get_energy_cost()
	# We wait for the action to apply. It's a coroutine, that is to say, an asynchronous function,
	# so we need to use yield.
	yield(action.apply_async(), "completed")
	battler_anim.move_back()
	# We reset the `_readiness`. The value can be greater than zero,
	# depending on the action.
	var readiness_saved = action.get_readiness_saved()
	_set_readiness(readiness_saved)
	if is_active:
		set_process(true)
	# We emit our new signal, indicating the end of a turn for a player-controlled character.
	emit_signal("action_finished")
	


func _on_BattlerAnim_animation_finished(anim_name):
	emit_signal("animation_finished", anim_name)


func is_fallen() -> bool:
	return stats.health <= 0


# This is the concrete instance of `ai_scene
var _ai_instance = null


# Allows the AI brain to get a reference to all battlers on the field.
func setup(battlers: Array) -> void:
	if ai_scene:
		# We instance the `ai_scene` and store a reference to it.
		_ai_instance = ai_scene.instance()
		# `BattlerAI.setup()` takes the actor and all battlers in the encounter.
		_ai_instance.setup(self, battlers)
		# Adding the instance as a child to trigger its `_ready()` callback.
		add_child(_ai_instance)


# Returns the `BattlerAI` instance attached to this battler.
# We wrap it in a method because our property is
# pseudo-private: we want it to be read-only.
func get_ai() -> Node:
	return _ai_instance
