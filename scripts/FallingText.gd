extends Position2D

onready var tween = $Tween
onready var label = $Label

# warning-ignore:unused_class_variable
var text setget set_text, get_text

# Called when the node enters the scene tree for the first time.
func _ready():
	modulate.a = 0
	
func start():
	tween.interpolate_property(self, "position",
		position + Vector2(0, 10),
		position,
		0.3, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	
	tween.interpolate_property(self, "modulate",
		Color(modulate.r, modulate.g, modulate.b, modulate.a),
		Color(modulate.r, modulate.g, modulate.b, 1.0),
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	
	tween.interpolate_property(self, "modulate",
		Color(modulate.r, modulate.g, modulate.b, 1.0),
		Color(modulate.r, modulate.g, modulate.b, 0.0),
		0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.5
	)
	
	tween.interpolate_property(self, "position",
		position,
		position + Vector2(0, 40),
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 1.5
	)
	
	tween.interpolate_callback(self, 2.0, "destroy")
	
	tween.start()

func set_text(new_text):
	label.text = str(new_text)

func get_text():
	return label.text

