extends Sprite

var zombie
var target
var isMiss = false
var miss_once = true
var velocity = Vector2(1, 0)
var stop_looking = false
export(float) var speed = 500

func _process(delta):
	# If we missed, first frame lets shoot some random thing.
	if isMiss && miss_once:
		miss_once = false
		target = get_miss_target()

	# If the zombie isn't null, bullet the forehead stupid
	if zombie != null:
		target = zombie.get_node('Target').global_position

	# Don't move till we have a target
	if target != null:
		if !stop_looking:
			look_at(target)
		global_position += velocity.rotated(rotation) * speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_zombie_freed(_z):
	zombie = null
	stop_looking = true

func get_miss_target():
	randomize()
	var x = rand_range(100 if randf() < 0.7 else -10, Global.screen_size.x / 2)
	# above or below screen by 40
	var y = -40 if randi() % 2 == 0 else Global.screen_size.y + 40
	return Vector2(x, y)


func _on_Hitbox_area_entered(area):
	if area.get_parent() == zombie:
		zombie.shot()
		queue_free()

func _on_Free_timer_timeout():
	queue_free()
