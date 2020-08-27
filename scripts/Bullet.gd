extends Sprite

var zombie
var target
var isMiss = false
var miss_once = true
var velocity = Vector2(1, 0)
export(float) var speed = 500

func _process(delta):
	# If we missed, first frame lets shoot some random thing.
	if isMiss && miss_once:
		miss_once = false
		# Fire at half the screen distance +- 20px
		randomize()
		var x = rand_range(-20, Global.screen_size.x / 2)
		# 50% top or bottom
		var y = -40 if randi() % 2 == 0 else Global.screen_size.y + 40
		target = Vector2(x, y)

	# If the zombie isn't null, bullet the forehead stupid
	if zombie != null:
		target = zombie.get_node('Target').global_position
		
	# Don't move till we have a target
	if target != null:
		look_at(target)
		global_position += velocity.rotated(rotation) * speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
