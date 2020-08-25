extends Node2D

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
onready var velocity = global_position.direction_to(Vector2(0, global_position.y))
var dead = false
var surge_flag = true

var equation
var answer

func _ready():
	global_position = Vector2(250, 250)
	$Overkill_timer.wait_time = overkill_time
	generate_equation()

func _process(delta):
	if !dead:
		speed = max(base_speed, speed - ((base_speed * speed_decay) * delta))
		
		if speed == base_speed && surge_flag:
			speed = base_speed * surge_multiplier
			$Surge_delay_timer.start()
			surge_flag = false

		global_position += velocity * speed * delta
	else:
		$Overkill_timer.start()
		# Spawn particles on hit
		# Start dying animation

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
	print(equation, " = ", answer)
	$Equation.text = equation

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

func _on_Overkill_timer_timeout():
	queue_free()
