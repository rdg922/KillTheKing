extends Node2D

var automatic = false;

var flip_on_rotation = true
export var weight : float = -50;
export var knockback_force : float = 1
var type = "sword"
var state = "idle"

onready var collision = $Collision

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
sync func init_shoot():

	$AnimationPlayer.play("swing")
	
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	
	if(anim_name == "swing"):
		var bodies = collision.get_overlapping_bodies()
		for body in bodies:
			if body.is_in_group("player") ||body.is_in_group("enemy"):
				var knockback = (Vector2(body.position.x, body.position.y) - get_parent().get_parent().position).normalized() * knockback_force
				body.state="hit"
				body.knockback_dir = knockback;
				body.knockback_timer = body.knockback_reset
				body.sprite.material = singleton.state_materials["hit"]
				body.rpc("change_health", -3)
				if(body.is_in_group("player")):
					body.rpc("disable_void_collision")
		$AnimationPlayer.play("end-swing")
		
	pass # Replace with function body.
