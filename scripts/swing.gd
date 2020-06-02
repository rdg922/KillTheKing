extends Area2D


onready var parent;


export var damage = 3
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = Vector2(cos(global_rotation), sin(global_rotation))
	if(len(get_overlapping_bodies()) > 0):
		var obj = get_overlapping_bodies()[0]
		if(obj.is_in_group("damageable")):
			singleton.camera.rpc("shake", 0.2, 30, 10)
			if(obj.is_in_group("player") and obj.state != "dash" and obj.state != "hit"):
				

				
				obj.state="hit"
				obj.knockback_dir = dir;
				obj.knockback_timer = obj.knockback_reset
				obj.sprite.material = singleton.state_materials["hit"]
				obj.rpc("change_health", -damage)
			
			if(obj.is_in_group("arrow")):
				global_rotation = dir;


func _on_AnimatedSprite_animation_finished():

	queue_free()
	pass # Replace with function body.
