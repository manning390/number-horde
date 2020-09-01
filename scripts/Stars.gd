extends Node2D

onready var tween = $Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	var delay = Global.start_time / Global.SKY_COLORS.size()
	tween.interpolate_property(self, "modulate",
		Color("00ffffff"),
		Color("ffffffff"),
		delay * 3, tween.TRANS_LINEAR, tween.EASE_IN_OUT, delay * 3)
		
func start():
	tween.start()
