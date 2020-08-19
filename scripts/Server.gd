extends Node

const PORT = 9080
var _server = WebSocketServer.new()
var crypto = Crypto.new()
var key = crypto.generate_rsa(4096)
var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=myorganisation,C=IT")

# Maps method strings to function calls
# See _on_data for call
var methodMap = {
	"fire": funcref(self, "_on_fire"),
}

var players = {}

# Called when the node enters the scene tree for the first time.
func _ready():
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
	_server.stop()

func _process(_delta):
	_server.poll()

func _on_close_request(id, code, reason):
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _onData(id):
	var pkt = parse_json(_server.get_peer(id).get_packet().get_string_from_utf8())
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
	# Record a new player
	var color = Global.rand_color()
	players[id] = {
		"id": id,
		"color": color
	}
	
	# Are we playing?
	var wait = 0
	# If so, instance player
	_sendPkt(id, "connected", {
		"id": id,
		"color": color,
		"wait": wait
	})
	
func _on_disconnect(id, was_clean = false):
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])
	# Remove Instance
	# Notify game player has left
	# Remove player
	players.erase(id)

func _on_fire(id, data):
	if randi() % 1 == 0:
		_sendPkt(id, "hit", {"equation":"1+1=2"})
	else:
		_sendPkt(id, "miss", {})


