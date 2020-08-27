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

func get_player_spawn_pos():
	randomize()
	return Vector2(rand_range(20, 250), rand_range((screen_size.y / 2) - 20, screen_size.y - 20))
	
func get_zombie_spawn_pos():
	randomize()
	return Vector2(screen_size.x + rand_range(20, screen_size.x / 2), rand_range((screen_size.y / 2) - 20, screen_size.y - 20))
	


