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

var term1
var term2
var operator
var equation
var answer
var score

export(float) var overkill_time = 1

var speed = base_speed
var dead = false
var surge_flag = true
var original_surge_delay # Saves the original timer value so our first surge is random
var first_surge = true

signal zombie_freed(zombie)
signal zombie_hit(player, eq, ans, score, first)

func start(equation_type):
	original_surge_delay = surge_timer.wait_time
	surge_timer.wait_time = rand_range(0.3, 2)
	overkill_timer.wait_time = overkill_time
	generate_equation(equation_type)

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

func generate_equation(equation_type):
	randomize()
	term1 = int(rand_range(min_term, max_term+1))
	term2 = int(rand_range(min_term, max_term+1))
	operator = equation_type

	# Let's not break math
	if term2 == 0 && operator == 3:
		return generate_equation(equation_type)

	answer = calc_answer(term1, term2, operator)
	score = calc_score()
	equation = "%d %s %d" % [term1, Global.operators[operator], term2]
#	print(equation, " = ", answer, " => ", score)
	equation_label.text = equation

func calc_answer(t1, t2, o):
	match o:
		0:
			return t1 + t2
		1:
			return t1 - t2
		2:
			return t1 * t2
		3:
			return float(t1) / float(t2)
		_:
			return 0

func _on_Surge_timer_timeout():
	surge_flag = true
	if first_surge:
		surge_timer.wait_time = original_surge_delay
		first_surge = false

func _on_Overkill_timer_timeout():
	queue_free()

func shot(player_id):
	if Global.node_creation_parent != null:
		var dmg = Global.instance_node(floating_text, target.global_position, Global.node_creation_parent)
		if !dead:
			dmg.set_color(Color(1,0,0))
		emit_signal("zombie_hit", player_id, equation, answer, score if !dead else score / 2, !dead)
		dmg.set_text(answer)
		dmg.start()
	if !dead:
		dead = true
		overkill_timer.start()

func calc_score():
	var out = 100
	if term1 > 5 && term1 < 9:
		out += 50
	if term2 > 5 && term2 < 9:
		out += 50
	if operator == 2 && (answer % 3 == 0 || answer % 8 == 0 || answer % 7 == 0 || answer % 6 == 0 || answer % 9 == 0):
		out += 100
	if operator == 3:
		out += 150
	out *= operator+1
	return out
