# Arena script only concerns itself with the "look" of the scene:
# - which sprites to load
# - sprite position, orientation

extends Node2D

onready var hills = $Train/Hills
onready var trees = $Train/Trees

export(float) var hills_scroll_speed = 0.01
export(float) var trees_scroll_speed = 0.07

func _ready():
	hills.material.set_shader_param("scroll_speed", hills_scroll_speed)
	trees.material.set_shader_param("scroll_speed", trees_scroll_speed)
