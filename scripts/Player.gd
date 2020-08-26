extends Sprite

var velocity = Vector2()
export(int) var walk_speed = 35
export(int) var min_wait_to_walk = 3
export(int) var max_wait_to_walk = 10

var can_shoot = true
var id

var walking = false
var target_pos = Vector2()

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

# func fire():
#	walking = false
#	$Random_walk_timer.start()

func _on_Random_walk_timer_timeout():
	randomize()
	target_pos = Vector2(randi() % 230 + 20, randi() % 560 + 20) # Stay between 0 and 250 and 20 and 580
	target_pos = Global.get_spawn_position(true)
	walking = true
