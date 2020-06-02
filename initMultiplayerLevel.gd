extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_player = preload("res://objects/player.tscn").instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	get_tree().get_root().get_node("Level/YSort").add_child(new_player)
	var info = Network.my_info
	new_player.init(info.position, false)
	
	pass # Replace with function body.

