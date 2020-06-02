extends Control


onready var single = get_node("/root/singleton")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Server_button_up():
	get_tree().change_scene("res://levels/floating.tscn")
	Network.create_server()
	pass # Replace with function body.


func _on_Client_button_up():
	Network.join_server()
	
	pass # Replace with function body.

