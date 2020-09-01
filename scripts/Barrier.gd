extends Node2D

var floating_text = preload("res://scenes/FloatingText.tscn")
onready var health_label = $Control/Health_label

var health = 100

signal death()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	health_label.text = str(health)
	if health > 0:
		if health < 50:
			health_label.set("custom_colors/font_color", Color.orange)
		elif health < 20:
			health_label.set("custom_colors/font_color", Color.red)
	else:
		emit_signal("death")
		queue_free()
