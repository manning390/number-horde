extends Node

var player_node = preload("res://scenes/Player.tscn")
var zombie_node = preload("res://scenes/Zombie.tscn")
var notify_node = preload("res://scenes/FallingText.tscn")

onready var countdown_label = $UI/Control/Countdown
onready var start_timer = $Start_timer
onready var corgi = $Corgi

var countdown_color = 0

var TEST = 0
const MOCK_PLAYERS = 20

var ip = "127.0.0.1"
const PORT = 9080

var _server = WebSocketServer.new()
#var _upnp = UPNP.new()
#var upnp_err = 1
#var crypto = Crypto.new()
# var key = crypto.generate_rsa(4096)
# var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=myorganisation,C=IT")

# Maps pkt method strings to function calls
# See _on_data for call
var methodMap = {
	"fire": funcref(self, "_on_fire"),
}

var players = {}
var zombies = []
var targetable_zombies = []

const MAX_NOTIFY = 6
var notify_queue = []

var game_started = false

# Called when the node enters the scene tree for the first time.
func _ready():
#	upnp_err = _upnp.discover()
##		print("Port mapping failed, will need to port forward")
#	if upnp_err == OK:
#		print("upnp OK")
#
#		print(_upnp.get_gateway().query_external_address())
#		_upnp.add_port_mapping(PORT)
#		var _ip = _upnp.query_external_address()
#		print("ext ip ", _ip)
#		if _ip != "":
#			ip = _ip
	
	Global.node_creation_parent = self
	_server.connect("client_connected", self, "_on_connect")
	_server.connect("client_disconnected", self, "_on_disconnect")
	_server.connect("client_close_request", self, "_on_close_request")
	_server.connect("data_received", self, "_on_data")
	
	# Having issues with WSS, will need to investigate
	#_server.private_key = key
	#_server.ssl_certificate = cert
	
	var err = _server.listen(PORT)
	if err != OK:
		print("Unable to start server")
		set_process(false)
	elif err == OK:
		print("Server started")
	
	for i in MOCK_PLAYERS:
		spawn_player(i, true)
	
	# Display our IP
#	$UI/Control/IP.text = "Server: %s:%d" % [ip, PORT]

	# Run first round of notifications immediately
	_on_Notify_timer_timeout()	

func _exit_tree():
	Global.node_creation_parent = null
	_server.stop()
#	if upnp_err == 0:
#		_upnp.delete_port_mapping(PORT)

func _process(delta):
	# Spawn a zombie for every player there is, negative numbers ignored
	if game_started:
		spawn_zombie(players.size() - zombies.size())
	else:
		update_countdown()
		
	TEST += delta
	if TEST >= 0.2:
		TEST = 0
		randomize()
		_on_fire(randi() % MOCK_PLAYERS, {"shot": randi() % 10})
		
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

func spawn_zombie(count):
	if Global.node_creation_parent == null || count <= 0:
		return
	for i in count:
		var z = Global.instance_node(zombie_node, Global.get_zombie_spawn_pos(), Global.node_creation_parent)
		z.connect("zombie_freed", self, "_on_zombie_freed")
		zombies.append(z)

func _on_zombie_freed(zombie):
	zombies.erase(zombie)

func spawn_player(id, isMock = false):
	# Create a new player
	var color = Global.rand_color()
	var pname = Global.rand_name()
	# Assuming 1024 x 600, 1/4 left side of screen with 30px m and full height with 20px m
	var player_instance = null
	if (Global.node_creation_parent != null):
		player_instance = Global.instance_node(player_node, Global.get_player_spawn_pos(), Global.node_creation_parent)
		player_instance.modulate = color
	
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
			"wait": 0
		})

func _on_close_request(id, code, reason):
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _on_data(id):
	var raw = _server.get_peer(id).get_packet().get_string_from_utf8()
	var pkt = parse_json(raw)
	print("Client %d sent %s" % [id, raw])
	if pkt.method in self.methodMap:
		self.methodMap[pkt.method].call_func(id, pkt.data)
	else:
		print("Client %d sent unsupported pkt method: %s d" % [id, pkt.method])

func _sendPkt(id, method, data):
	_server.get_peer(id).put_packet(to_json({
		"method": method,
		"data": data
	}).to_utf8())

func _on_connect(id, _proto):
	print("Client %d connected" % [id])
	spawn_player(id)

func _on_disconnect(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	# Notify game player has left
	notify("Player %d disconnected" % [id])
	# Remove Instance
	players[id].instance.queue_free()
	# Remove player
	players.erase(id)

func _on_fire(id, data):
	if game_started:
		#	print("player: ", id, " shot ", data.shot)
			targetable_zombies = get_targetable_zombies()
			for z in targetable_zombies:
				if z.answer == data.shot:
					players[id].instance.fire(z)
		#			_sendPkt(id, "hit", {"equation": z.equation})
					return
			players[id].instance.fire(null)
		#	_sendPkt(id, "miss", {})

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
