extends Node2D

onready var floating_text = preload("res://scenes/FloatingText.tscn")

onready var overkill_timer = $Overkill_timer
onready var equation_label = $ZLayer/Equation
onready var surge_timer = $Surge_delay_timer
onready var target = $Target

export(int) var base_speed = 20
export(float) var surge_multiplier = 3.5
export(float) var speed_decay = 7

export(int) var min_term = 0
export(int) var max_term = 9
export(int, "addition", "subtraction", "multiplication", "division") var allowed_operators = 0

export(float) var overkill_time = 1

var operators = {
	0: "+",
	1: "-",
	2: "x",
	3: "/",
}
var speed = base_speed
var dead = false
var surge_flag = true
var original_surge_delay # Saves the original timer value so our first surge is random
var first_surge = true

var equation
var answer


signal zombie_freed(zombie)

func _ready():
	original_surge_delay = surge_timer.wait_time
	surge_timer.wait_time = rand_range(0.3, 2)
	overkill_timer.wait_time = overkill_time
	generate_equation()

func _exit_tree():
	emit_signal("zombie_freed", self)

func _process(delta):
	if !dead:
		speed = max(base_speed, speed - ((base_speed * speed_decay) * delta))
		
		if speed == base_speed && surge_flag:
			speed = base_speed * surge_multiplier
			surge_timer.start()
			surge_flag = false

		global_position += Vector2(-1, 0) * speed * delta
		
		# Technically this shouldn't happen because of the barricade but eh?
		if global_position.x < -30:
			queue_free()

func generate_equation():
	randomize()
	var term1 = int(rand_range(min_term, max_term+1))
	var term2 = int(rand_range(min_term, max_term+1))
	var operator = int(rand_range(0, allowed_operators+1))
	
	# Let's not break math
	if term2 == 0 && operator == 3:
		return generate_equation()

	answer = calc_answer(term1, term2, operator)
	equation = "%d %s %d" % [term1, operators[operator], term2]
#	print(equation, " = ", answer)
	equation_label.text = equation

func calc_answer(term1, term2, operator):
	match(operator):
		0:
			return term1 + term2
		1:
			return term1 - term2
		2:
			return term1 * term2
		3:
			return float(term1) / float(term2)
		_:
			return 0

func _on_Surge_timer_timeout():
	surge_flag = true
	if first_surge:
		surge_timer.wait_time = original_surge_delay
		first_surge = false

func _on_Overkill_timer_timeout():
	queue_free()

func shot():
	if Global.node_creation_parent != null:
		var dmg = Global.instance_node(floating_text, target.global_position, Global.node_creation_parent)
		if !dead:
			dmg.set_color(Color(1,0,0))
		dmg.set_text(answer)
		dmg.start()
	if !dead:
		dead = true
		overkill_timer.start()