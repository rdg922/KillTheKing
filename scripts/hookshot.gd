extends Node2D

var automatic = false;
var flip_on_rotation = false
export var weight : float = 0;
var type = "gun"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Gun.player = get_parent().get_parent()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
sync func init_shoot():
	if(has_node("Gun")):
		$Gun.init_shoot()
	pass
