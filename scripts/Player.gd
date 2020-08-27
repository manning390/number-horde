extends Sprite

var bullet_node = preload("res://scenes/Bullet.tscn")

var velocity = Vector2()
export(int) var walk_speed = 35
export(int) var min_wait_to_walk = 3
export(int) var max_wait_to_walk = 10

var can_shoot = true
var id

var walking = false
var target_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if walking:
		velocity = global_position.direction_to(target_pos)
		global_position += velocity * walk_speed * delta
		if global_position.distance_to(target_pos) < walk_speed:
			walking = false
			randomize()
			$Random_walk_timer.wait_time = randi() % (max_wait_to_walk - min_wait_to_walk) + min_wait_to_walk
			$Random_walk_timer.start()
			target_pos = null

func fire(zombie):
	if Global.node_creation_parent != null:
		# Stop walking for half a second then resume, same target
		walking = false
		$Random_walk_timer.wait_time = 0.5
		$Random_walk_timer.start()
		var bullet = Global.instance_node(bullet_node, $Gun_position.global_position, Global.node_creation_parent)
		if zombie != null:
			bullet.zombie = zombie
		else:
			bullet.isMiss = true

func _on_Random_walk_timer_timeout():
	randomize()
	if target_pos == null:
		target_pos = Global.get_player_spawn_pos()
	walking = true
