extends Sprite

var can_shoot = true
var id

var walking = false
var target_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if walking:
		global_position = lerp(global_position, target_pos, 2)

func _on_Random_walk_timer_timeout():
	target_pos = Vector2(randi() % 224 + 30, randi() % 580 + 20)
	walking = true

func set_player_colors(color_head, color_body):
	pass
