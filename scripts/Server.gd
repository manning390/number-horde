extends Node

var player_node = preload("res://scenes/Player.tscn")
var zombie_node = preload("res://scenes/Zombie.tscn")
var notify_node = preload("res://scenes/FallingText.tscn")
var barricade_node = preload("res://scenes/Barricade.tscn")

onready var score_label = $UI/Control/Score
onready var countdown_label = $UI/Control/Countdown
onready var start_timer = $Start_timer
onready var difficulty_timer = $Difficulty_timer
onready var gameover_timer = $Gameover_timer
onready var sky_node = $Sky_layer/Sky
onready var stars_node = $Sky_layer/Stars

var countdown_color = 0

var TOTAL_BARRICADES = 4
var TEST = 0
const MOCK_PLAYERS = 2

const PORT = 443

var _server = WebSocketServer.new()

# Maps pkt method strings to function calls
# See _on_data for call
# Totes overkill
var methodMap = {
	"fire": funcref(self, "shoot"),
}

var players = {}
var zombies = []
var targetable_zombies = []

const MAX_NOTIFY = 6
var notify_queue = []

var game_started = false
var game_over = false
var zombie_difficulty = Global.difficulty.EASY
var timer_reset_count = 0
var max_zombie_spawn = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	# Cert stuff
	_server.bind_ip = "*"
	_server.private_key = CryptoKey.new();
	_server.private_key.load("res://keys/privkey.key")
	_server.ssl_certificate = X509Certificate.new()
	_server.ssl_certificate.load("res://keys/cert.crt")
	_server.ca_chain = X509Certificate.new()
	_server.ca_chain.load("res://keys/chain.crt")

	Global.node_creation_parent = self
	_server.connect("client_connected", self, "_on_connect")
	_server.connect("client_disconnected", self, "_on_disconnect")
	_server.connect("client_close_request", self, "_on_close_request")
	_server.connect("data_received", self, "_on_data")

	var err = _server.listen(PORT)
	if err != OK:
		print("Unable to start server")
		set_process(false)
	elif err == OK:
		print("Server started")

	# Run first round of notifications immediately
	_on_Notify_timer_timeout()

func _exit_tree():
	Global.node_creation_parent = null
	_server.stop()

func _process(delta):
	# Spawn a zombie for every player there is, negative numbers ignored
	if game_started:
		spawn_zombie(max_zombie_spawn - zombies.size(), zombie_difficulty)
	elif !start_timer.is_stopped():
		update_countdown()

	_server.poll()

func get_targetable_zombies():
	var out = []
	for z in zombies:
		if z.global_position.x < Global.screen_size.x && z.global_position.x > 0:
			out.append(z)
	out.sort_custom(self, "sort_zombie_distance")
	return out

static func sort_zombie_distance(a, b):
	if a.global_position.x < b.global_position.x:
		return true
	return false

func spawn_zombie(count, diff):
	if Global.node_creation_parent == null || count <= 0:
		return
	for i in count:
		var equation_type = randi() % (Global.difficulty_operators_map[diff] + 1)
		var z = Global.instance_node(zombie_node, Global.get_zombie_spawn_pos(), Global.node_creation_parent)
		z.connect("zombie_freed", self, "_on_zombie_freed")
		z.connect("zombie_hit", self, "_on_zombie_hit")
		z.start(equation_type)
		zombies.append(z)

func _on_zombie_freed(zombie):
	zombies.erase(zombie)

func _on_zombie_hit(player_id, equation, answer, points, first):
	Global.score += points
	score_label.text = "SCORE\n%d" % Global.score
	if players[player_id] != null:
		_sendPkt(player_id, "hit", {
			"equation": equation,
			"answer": answer,
			"points": points,
			"first": first
		})

func spawn_barricades():
	for i in TOTAL_BARRICADES:
		var b = Global.instance_node(barricade_node, Global.get_barricade_spawn_pos(i), Global.node_creation_parent)
		b.connect("barricade_created", self, "_on_barricade_created")
		b.connect("barricade_hit", self, "_on_barricade_hit")

func spawn_player(id, isMock = false):
	# Create a new player
	var color = Global.rand_color()
	var pname = Global.rand_name()
	# Assuming 1024 x 600, 1/4 left side of screen with 30px m and full height with 20px m
	var player_instance = null
	if (Global.node_creation_parent != null):
		player_instance = Global.instance_node(player_node, Global.get_player_spawn_pos(), Global.node_creation_parent)
		player_instance.id = id
		player_instance.set_color(color)

	players[id] = {
		"id": id,
		"name": pname,
		"color": color,
		"instance": player_instance
	}

	notify("Player %s connected" % [pname])

	# Tell client the info
	if !isMock:
		_sendPkt(id, "connected", {
			"id": id,
			"name": pname,
			"color": color.to_html().right(2), # Remove alpha channel
			"wait": start_timer.time_left * 1000 if start_timer != null else 0
		})

func _on_close_request(id, code, reason):
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _on_data(id):
	var raw = _server.get_peer(id).get_packet().get_string_from_utf8()
	var pkt = parse_json(raw)
	print("Client %d sent %s" % [id, raw])
	if pkt.method in methodMap:
		methodMap[pkt.method].call_func(id, pkt.data)
	else:
		print("Client %d sent unsupported pkt method: %s d" % [id, pkt.method])

func _sendPkt(id, method, data):
	if _server.has_peer(id):
		_server.get_peer(id).put_packet(to_json({
			"method": method,
			"data": data
		}).to_utf8())

func _on_connect(id, _proto):
	print("Client %d connected" % [id])
	if players.size() == 0:
		start_timer.wait_time = Global.start_time
		start_timer.start()
		sky_node.start()
		stars_node.start()
	spawn_player(id)

func _on_disconnect(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	# Notify game player has left
	notify("Player %s disconnected" % [players[id].name])
	# Remove Instance
	players[id].instance.queue_free()
	# Remove player
	players.erase(id)

func shoot(player_id, data):
	if game_started:
		#	print("player: ", id, " shot ", data.shot)
			targetable_zombies = get_targetable_zombies()
			for z in targetable_zombies:
				if z.answer == int(data.shot):
					players[player_id].instance.shoot(z)
					return
			players[player_id].instance.shoot(null)
			_sendPkt(player_id, "miss", {})

func notify(text):
	notify_queue.append(text)

func _on_Notify_timer_timeout():
	var notification_count  = notify_queue.size()
	if Global.node_creation_parent != null && notification_count > 0:
		var text = notify_queue.pop_front()
		for i in min(notification_count, MAX_NOTIFY)-1:
			text += "\n" + notify_queue.pop_front()
		var notify_inst = Global.instance_node(notify_node, Vector2(20, 20), Global.node_creation_parent)
		notify_inst.set_text(text)
		notify_inst.start()

func _on_Start_timer_timeout():
	game_started = true
	difficulty_timer.start()
	countdown_color = 0
	start_timer.queue_free()
	countdown_label.queue_free()

func update_countdown():
	# 0 => white, 1 => yellow, 2 => orange, 3 => red
	if countdown_color <= 0 && start_timer.time_left  <= (start_timer.wait_time / 2):
		countdown_color = 1
		countdown_label.set("custom_colors/font_color", Color.yellow)
	elif countdown_color <= 1 && start_timer.time_left <= 30:
		countdown_color = 2
		countdown_label.set("custom_colors/font_color", Color.orange)
	elif countdown_color <= 2 && start_timer.time_left <= 10:
		countdown_color = 3
		countdown_label.set("custom_colors/font_color", Color.red)
	countdown_label.text = "%d seconds\n until night falls" % [int(start_timer.time_left)]

func _on_Difficulty_timer_timeout():
	timer_reset_count += 10
	if zombie_difficulty != Global.difficulty.HARD:
		for d in Global.difficulty.values():
			if timer_reset_count < d:
				zombie_difficulty = d
				break

	var m = 2*PI
	max_zombie_spawn = (1/m)*timer_reset_count + players.size()*(1/m) + 5

func _on_Barrier_death():
	gameover_timer.start()

func _on_Gameover_timer_timeout():
	game_over = true
	for p in players:
		_sendPkt(players[p].id, "gameover", {})
	get_tree().change_scene("res://scenes/GameOver.tscn")
