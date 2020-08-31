extends Node2D

onready var body = $Body
onready var head = $Head
onready var walk_timer = $Random_walk_timer
onready var gun_pos = $Gun_position
onready var text_pos = $Text_position

var floating_text = preload("res://scenes/FloatingText.tscn")
var bullet_node = preload("res://scenes/Bullet.tscn")

var velocity = Vector2()
export(int) var walk_speed = 35
export(int) var min_wait_to_walk = 3
export(int) var max_wait_to_walk = 10

var can_shoot = true
var id

var cur_anim
var walking = false
var target_pos = null

# Called when the node enters the scene tree for the first time.
func _ready():
	head.modulate = Global.rand_skin()
	change_anim("down")
	body.playing = false

func _process(delta):
	if walking:
		velocity = global_position.direction_to(target_pos)
		var delta_to_target = global_position - target_pos
		if abs(delta_to_target.x) > abs(delta_to_target.y):
			# Horz
			if delta_to_target.x > 0:
				change_anim("left")
			else:
				change_anim("right")
		else:
			# Vert
			if delta_to_target.y > 0:
				change_anim("up")
			else:
				change_anim("down")
		
		global_position += velocity * walk_speed * delta
		if global_position.distance_to(target_pos) < walk_speed:
			body.playing = false
			walking = false
			target_pos = null
			
			randomize()
			walk_timer.wait_time = randi() % (max_wait_to_walk - min_wait_to_walk) + min_wait_to_walk
			walk_timer.start()
			

func fire(zombie):
	if Global.node_creation_parent != null:
		# Animation fire
		change_anim("fire")
		
		# Stop walking for half a second then resume, same target
		walking = false
		walk_timer.wait_time = 0.5
		walk_timer.start()

		var bullet = Global.instance_node(bullet_node, gun_pos.global_position, Global.node_creation_parent)
		bullet.modulate = body.modulate
		
		# Tell the bullet zombie inst or if it's a miss
		if zombie != null:
			bullet.zombie = zombie
			# If zombie despawns while bullet flying, tell it
			zombie.connect("zombie_freed", bullet, "_on_zombie_freed")
		else:
			bullet.isMiss = true
			var miss = Global.instance_node(floating_text, text_pos.global_position, Global.node_creation_parent)
			miss.set_text("Miss")
			miss.start()

func _on_Random_walk_timer_timeout():
	randomize()
	if target_pos == null:
		target_pos = Global.get_player_spawn_pos()
	walking = true
	change_anim(cur_anim)
	body.playing = true

func flip_h(flip):
	body.flip_h = flip
	head.flip_h = flip

func set_color(col):
	body.modulate = col

func change_anim(anim):
	if cur_anim != anim:
		cur_anim = anim
		body.frame = 0
		match anim:
			"up":
				flip_h(false)
				head.frame = 2
				body.animation = anim
			"down":
				flip_h(false)
				head.frame = 1
				body.animation = anim
			"left":
				flip_h(true)
				head.frame = 0
				body.animation = "right"
			"right":
				flip_h(false)
				head.frame = 0
				body.animation = anim
			"fire":
				flip_h(false)
				head.frame = 0
				body.animation = anim
