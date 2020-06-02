extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var SPEED : int = 500
export var life : float = .25
export var damage = 1;

onready var singleton = get_node("/root/singleton")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var rot = global_rotation
	var dir = Vector2(cos(rot), sin(rot)).normalized()
	
	global_position += dir * SPEED * delta
	life -= delta
	
	if(len(get_overlapping_bodies()) > 0):
		var obj = get_overlapping_bodies()[0]
		if(obj.is_in_group("damageable")):
			singleton.camera.rpc("shake", 0.2, 30, 10)
			if((obj.is_in_group("player") and obj.state != "dash" and obj.state != "hit") or (obj.is_in_group("enemy")    )   ):
				obj.state="hit"
				obj.knockback_dir = dir;
				obj.knockback_timer = obj.knockback_reset
				obj.sprite.material = singleton.state_materials["hit"]
				obj.rpc("change_health", -damage)
			
			if(obj.is_in_group("arrow")):
				global_rotation = dir;
				
		queue_free()
	
	if(life <= 0):
		queue_free()
	
	pass
