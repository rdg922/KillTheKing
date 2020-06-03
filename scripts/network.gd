extends Node


const SERVER_PORT := 8080
const SERVER_IP := "127.0.0.1"
const MAX_PLAYERS := 2

var is_server : bool = false
var is_client : bool = false

var networking_peer;

func _ready():
#	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _process(delta):
	if(is_server):
		if networking_peer.is_listening():
			networking_peer.poll()
	elif(is_client):
		
		var status = networking_peer.get_connection_status()
		
		if(status == NetworkedMultiplayerPeer.CONNECTION_CONNECTED || status == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
			networking_peer.poll()

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = {position = Vector2(53.048, 43) }

#func _player_connected(id):
#	# Called on both clients and server when a peer connects. Send my info to it.
#	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	player_info[get_tree().get_network_unique_id()] = my_info
	rpc('_send_player_info', get_tree().get_network_unique_id(), my_info)
	get_tree().change_scene("res://levels/floating.tscn")
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	get_tree().set_network_peer(null)
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func _send_player_info(id, info):
	if(get_tree().is_network_server()):
		for peer_id in player_info:
			rpc_id(id, '_send_player_info', peer_id, player_info[peer_id])
	player_info[id] = info
	
	var new_player = load('res://objects/player.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	get_tree().get_root().get_node("Level/YSort").add_child(new_player)
	new_player.position = Vector2(53.048, 43)
	

remote func update_position(id, position):
	player_info[id].position = position
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func create_server():
	
	player_info[1] = my_info
	
	var peer := WebSocketServer.new()
	peer.listen(SERVER_PORT, PoolStringArray(), true);
	peer.set_bind_ip(SERVER_IP)
	get_tree().set_network_peer(peer)
	print(IP.resolve_hostname("localhost"))
	
	is_server = true
	networking_peer = peer
	pass

func join_server(ip : String, port:= null):
	var peer = WebSocketClient.new()
	var url = "ws://" + ip
	if(port != null):
		url + ':' + str(port)
	var error = peer.connect_to_url(url, PoolStringArray(), true);
	get_tree().set_network_peer(peer)
	
	is_client = true
	networking_peer = peer
	pass
