extends Node

onready var screen_size = get_viewport().size
var node_creation_parent = null

func instance_node(node, location, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance

func rand_color():
	randomize()
	return Color.from_hsv(randf(), 1, 1)

func get_spawn_position(isPlayer = false):
	randomize()
	if isPlayer:
		return Vector2(rand_range(20, 250), rand_range((screen_size.y / 2) - 20, screen_size.y - 20))
	else:
		return Vector2(screen_size.x + rand_range(20, 60), rand_range((screen_size.y / 2) - 20, screen_size.y - 20))
