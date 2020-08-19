extends Node

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

var player = preload("res://Player.tscn")

var players = {}

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

func _exit_tree():
	Global.node_creation_parent = null
	_server.stop()

func _process(_delta):
	_server.poll()

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
	
	# Create a new player
	var color = Global.rand_color()
	# Assuming 1024 x 600, 1/4 left side of screen with 30px m and full height with 20px m	
	var player_instance = null
	if (Global.node_creation_parent != null):
		var pos = Vector2(randi() % 226 + 30, randi() % 580 + 20)
		player_instance = Global.instance_node(player, pos, Global.node_creation_parent)
		player_instance.modulate = color
	
	players[id] = {
		"id": id,
		"color": color,
		"ref": player_instance
	}
	
	# Tell client the info
	_sendPkt(id, "connected", {
		"id": id,
		"color": color.to_html().right(2), # Remove alpha channel
		"wait": next_wave
	})
	
func _on_disconnect(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	# Notify game player has left
	# Remove Instance
	players[id].ref.queue_free()
	# Remove player
	players.erase(id)

func _on_fire(id, data):
	if randi() % 2 == 0:
		_sendPkt(id, "hit", {"equation":"1+1=2"})
	else:
		_sendPkt(id, "miss", {})


