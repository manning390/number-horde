extends Node

const PORT = 9080
var _server = WebSocketServer.new()
var crypto = Crypto.new()
var key = crypto.generate_rsa(4096)
var cert = crypto.generate_self_signed_certificate(key, "CN=localhost,O=myorganisation,C=IT")

# Called when the node enters the scene tree for the first time.
func _ready():
	_server.connect("client_connected", self, "_connected")
	_server.connect("client_disconnected", self, "_disconnected")
	_server.connect("client_close_request", self, "_close_request")
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

func _connected(id, proto):
	print("Client %d connected with protocol: %s" % [id, proto])
	_send(id, "Hello there!")

func _close_request(id, code, reason):
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])
	
func _disconnected(id, was_clean = false):
	 print("Client %d disconnected, clean: %s" % [id, str(was_clean)])

	
func _on_data(id):
	var pkt = _server.get_peer(id).get_packet()
	print("Got data from client %d: %s ... echoing" % [id, pkt.get_string_from_utf8()])
	_server.get_peer(id).put_packet(pkt)

func _process(_delta):
	_server.poll()

func _send(id, msg):
	_server.get_peer(id).put_packet(msg.to_utf8())
