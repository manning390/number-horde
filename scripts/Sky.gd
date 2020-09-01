extends Sprite

onready var tween = $Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	var colors = Global.SKY_COLORS
	modulate = colors[0]
	var delay = Global.start_time / colors.size()
	for i in colors.size()-1:
#		print(colors[i], " ", colors[i+1], " ", delay, " ", delay * i)
		tween.interpolate_property(self, "modulate",
			colors[i],
			colors[i+1],
			delay, tween.TRANS_LINEAR, tween.EASE_IN_OUT, delay * i)

func start():
	tween.start()
