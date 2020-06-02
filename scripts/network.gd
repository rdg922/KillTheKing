extends Node


const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"
const MAX_PLAYERS = 2

func _ready():
#	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

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
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	
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
	
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
	print(IP.get_local_addresses())
	print("hi")
	pass

func join_server():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().network_peer = peer
	pass
