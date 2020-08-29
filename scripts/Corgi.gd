extends Sprite

onready var anim = $AnimationPlayer
onready var walk_timer = $Walk_timer
export(int) var walk_speed = 35
export(int) var min_wait_to_walk = 3
export(int) var max_wait_to_walk = 10

var target_pos
var walking = false
var velocity = Vector2()
var delta_to_target
var is_horizontal

var cur_anim

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(100,100)
	change_anim("down")
	stop_anim()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if walking:
		delta_to_target = global_position - target_pos

		print(delta_to_target)
		if is_horizontal:
			change_anim("right")
			print("fuck")
			if delta_to_target.x > 0:
				print("fucky")
				velocity = Vector2(-1, 0)
				flip_h = true
			elif delta_to_target.x < 0:
				print("ffffff")
				velocity = Vector2(1, 0)
				flip_h = false
		else:
			print("shit")
			if delta_to_target.y > 0:
				print("shitty")
				velocity = Vector2(0, -1)
				change_anim("up")
			elif delta_to_target.y < 0:
				print("ssshhhhhiiiiiit")
				velocity = Vector2(0, 1)
				change_anim("down")

		if abs(delta_to_target.x) < walk_speed * delta and delta_to_target.x != 0:
			print("bluggh")
			global_position.x = target_pos.x
			is_horizontal = false
		elif abs(delta_to_target.y) < walk_speed * delta and delta_to_target.y != 0:
			print("blargh")
			global_position.y = target_pos.y
			is_horizontal = true
		else:
			print("nani")
			global_position += velocity * walk_speed * delta
		
		if delta_to_target == Vector2():
			walking = false
#			stop_anim()
			randomize()
			walk_timer.wait_time = randi() % (max_wait_to_walk - min_wait_to_walk) + min_wait_to_walk
			walk_timer.start()
			target_pos = null
	else:
		stop_anim()

func change_anim(new_anim):
	if cur_anim != new_anim:
		anim.play(new_anim)
		cur_anim = new_anim

func stop_anim():
	anim.stop()
	cur_anim = null
	anim.advance(0)

func _on_Walk_timer_timeout():
	randomize()
	if target_pos == null:
		target_pos = Global.get_player_spawn_pos()
	walking = true
	delta_to_target = global_position - target_pos
	is_horizontal = randf() > 0.5

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == BUTTON_LEFT:
		if get_rect().has_point(event.position):
			print('test')
			get_tree().set_input_as_handled() # if you don't want subsequent input callbacks to respond to this input
