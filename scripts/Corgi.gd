extends AnimatedSprite

onready var walk_timer = $Walk_timer
export(int) var walk_speed = 35
export(int) var min_wait_to_walk = 3
export(int) var max_wait_to_walk = 10

var target_pos
var walking = false
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(100,100)
	animation = "down_walk"
	frame = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if walking:
		playing = true
		velocity = global_position.direction_to(target_pos)
		global_position += velocity * walk_speed * delta
		
		var delta_to_target = global_position - target_pos
		if abs(delta_to_target.x) > abs(delta_to_target.y):
			# Moving more horizontal than vertical
			if delta_to_target.x > 0:
				animation = "left_walk"
			else:
				animation = "right_walk"
		else:
			if delta_to_target.y > 0:
				animation = "up_walk"
			else:
				animation = "down_walk"
		
		if global_position.distance_to(target_pos) < walk_speed:
			walking = false
			frame = 0
			randomize()
			walk_timer.wait_time = randi() % (max_wait_to_walk - min_wait_to_walk) + min_wait_to_walk
			walk_timer.start()
			target_pos = null
	else:
		playing = false


func _on_Walk_timer_timeout():
	randomize()
	if target_pos == null:
		target_pos = Global.get_player_spawn_pos()
	walking = true

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == BUTTON_LEFT:
		if get_rect().has_point(event.position):
			print('test')
			get_tree().set_input_as_handled() # if you don't want subsequent input callbacks to respond to this input
