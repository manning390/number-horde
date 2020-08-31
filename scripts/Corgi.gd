extends Sprite

var heart = preload("res://scenes/Heart.tscn")

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
	global_position = Global.get_player_spawn_pos()
	change_anim("down")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if walking:
		delta_to_target = global_position - target_pos
		if delta_to_target == Vector2():
			walking = false
			randomize()
			walk_timer.wait_time = 1#randi() % (max_wait_to_walk - min_wait_to_walk) + min_wait_to_walk
			walk_timer.start()
			target_pos = null
			return
			
		if is_horizontal:
			change_anim("right", true)
			if delta_to_target.x > 0:
				velocity = Vector2(-1, 0)
				flip_h = true
			elif delta_to_target.x < 0:
				velocity = Vector2(1, 0)
				flip_h = false
		else:
			flip_h = false
			if delta_to_target.y > 0:
				velocity = Vector2(0, -1)
				change_anim("up")
			elif delta_to_target.y < 0:
				velocity = Vector2(0, 1)
				change_anim("down")

		if abs(delta_to_target.x) < walk_speed * delta and delta_to_target.x != 0:
			global_position.x = target_pos.x
			is_horizontal = false
		elif abs(delta_to_target.y) < walk_speed * delta and delta_to_target.y != 0:
			global_position.y = target_pos.y
			is_horizontal = true
		else:
			global_position += velocity * walk_speed * delta
	else:
		stop_anim()

func change_anim(new_anim, force = false):
	if cur_anim != new_anim or force:
		anim.play(new_anim)
		cur_anim = new_anim

func stop_anim():
	if cur_anim != null:
		anim.stop(true)
		match cur_anim:
			"up":
				frame = 3
			"down":
				frame = 0
			"right":
				frame = 9
		cur_anim = null

func _on_Walk_timer_timeout():
	randomize()
	if target_pos == null:
		target_pos = Global.get_player_spawn_pos()
	walking = true
	delta_to_target = global_position - target_pos
	randomize()
	is_horizontal = randf() > 0.5

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			randomize()
			if Global.node_creation_parent != null:
				Global.instance_node(heart, $Heart_spawn.global_position, Global.node_creation_parent)
			
