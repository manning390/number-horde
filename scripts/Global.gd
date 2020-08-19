extends Node

var node_creation_parent = null

func instance_node(node, location, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance

func rand_color():
	return Color.from_hsv(randf(), 1, 1)
