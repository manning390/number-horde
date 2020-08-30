extends Sprite

export(int) var speed = 30
export(int) var waver_dist = 10

var first = true
var delta_sum = 0


func _process(delta):
	delta_sum += delta
	if first:
		randomize()
		global_position.x += rand_range(-1 * waver_dist * 2, 15)
		first = false
	global_position += Vector2(sin(delta_sum), -1) * Vector2(waver_dist, speed) * delta

func _on_Free_timer_timeout():
	queue_free()
