extends Node

var player_node = preload("res://scenes/Player.tscn")
var zombie_node = preload("res://scenes/Zombie.tscn")

var TEST = 0

const PORT = 9080
var _server = WebSocketServer.new()
var crypto = Crypto.new()
# var key = crypto.generate_rsa(4096)
# var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=myorganisation,C=IT")

var next_wave = 0

# Maps pkt method strings to function calls
# See _on_data for call
var methodMap = {
	"fire": funcref(self, "_on_fire"),
}

var players = {}
var zombies = []
var targetable_zombies = []

# Called when the node enters the scene tree for the first time.
func _ready():
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
	
	for i in 2:
		spawn_player(i, true)

func _exit_tree():
	Global.node_creation_parent = null
	_server.stop()

func _process(delta):
	# Spawn a zombie for every player there is, negative numbers ignored
	spawn_zombie(players.size() - zombies.size())
		
		
	TEST += delta
	if TEST >= 0.5:
		TEST = 0
		randomize()
		_on_fire(1, {"shot": randi() % 21})
		
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
	# Assuming 1024 x 600, 1/4 left side of screen with 30px m and full height with 20px m	
	var player_instance = null
	if (Global.node_creation_parent != null):
		player_instance = Global.instance_node(player_node, Global.get_player_spawn_pos(), Global.node_creation_parent)
		player_instance.modulate = color
	
	players[id] = {
		"id": id,
		"color": color,
		"instance": player_instance
	}
	
	# Tell client the info
	if !isMock:
		_sendPkt(id, "connected", {
			"id": id,
			"color": color.to_html().right(2), # Remove alpha channel
			"wait": next_wave
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

func _on_connect(id, proto):
	print("Client %d connected" % [id])
	
	spawn_player(id)

func _on_disconnect(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	# Notify game player has left
	# Remove Instance
	players[id].instance.queue_free()
	# Remove player
	players.erase(id)

func _on_fire(id, data):
#	print("player: ", id, " shot ", data.shot)
	targetable_zombies = get_targetable_zombies()
	for z in targetable_zombies:
		if z.answer == data.shot:
			players[id].instance.fire(z)
#			_sendPkt(id, "hit", {"equation": z.equation})
			return
	players[id].instance.fire(null)
#	_sendPkt(id, "miss", {})
