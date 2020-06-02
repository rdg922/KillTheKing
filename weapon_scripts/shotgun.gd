extends Node2D

export var weight = 20;
var flip_on_rotation = true;
var automatic = false;
var type = "gun"


onready var bullet : Resource = preload("res://objects/bullet.tscn")
onready var spawnPoint : Position2D = $Position2D
onready var singleton = get_node("/root/singleton")

var will_shoot = false



export var bulletLife : float = .15;

export var bulletOffsetAngle : float = 20
# Called when the node enters the scene tree for the first time.
func _process(delta):
	
	if(will_shoot && $AnimationPlayer.current_animation != "shoot"):
		var bulletInst : Area2D = bullet.instance()
		get_tree().get_root().get_node("Level").add_child(bulletInst)
		bulletInst.global_position = get_spawn_point()
		bulletInst.global_rotation = global_rotation - deg2rad(bulletOffsetAngle)
		bulletInst.life = bulletLife
		
		bulletInst = bullet.instance()
		get_tree().get_root().get_node("Level").add_child(bulletInst)
		bulletInst.global_position = get_spawn_point()
		bulletInst.global_rotation = global_rotation + deg2rad(bulletOffsetAngle)
		bulletInst.life = bulletLife
		
		bulletInst = bullet.instance()
		get_tree().get_root().get_node("Level").add_child(bulletInst)
		bulletInst.global_position = get_spawn_point()
		bulletInst.global_rotation = global_rotation
		bulletInst.life = bulletLife
		
		will_shoot = false
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

sync func init_shoot():
	
	$AnimationPlayer.current_animation = ("shoot")
	will_shoot = true

	pass

func get_spawn_point() -> Vector2:
	return spawnPoint.global_position
