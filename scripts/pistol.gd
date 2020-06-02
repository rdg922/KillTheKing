extends Node2D

export var weight : float = 0;

onready var bullet : Resource = preload("res://objects/bullet.tscn")
onready var spawnPoint : Position2D = $Position2D
onready var singleton = get_node("/root/singleton")

#var will_shoot = false
var client = true

var automatic = false;
var will_shoot = false;

var type = "gun"

export var bulletLife = .5;
export var bulletOffsetY : float = 0;
export var bulletOffsetAngle : float = 5;

export var countdown = 0.1;
var timer = 0;
var dt = 0;
var flip_on_rotation = true

# Called when the node enters the scene tree for the first time.
func _process(delta):
	dt = delta
	timer -=dt;
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

sync func init_shoot():
	
#	print(timer)
	if(timer <= 0):
		var bulletInst : Area2D = bullet.instance()
		
		bulletInst = bullet.instance()
		get_tree().get_root().get_node("Level").add_child(bulletInst)
		bulletInst.global_position = get_spawn_point()
		bulletInst.global_rotation = global_rotation;
		bulletInst.global_position.y += rand_range(-bulletOffsetY, bulletOffsetY)
		bulletInst.global_rotation += deg2rad(rand_range(-bulletOffsetAngle, bulletOffsetAngle))
		
		timer = countdown;
		bulletInst.life = bulletLife;
		$AnimationPlayer.current_animation = "shoot"
	
	will_shoot = true
#	print(will_shoot)

	pass

func get_spawn_point() -> Vector2:
	return spawnPoint.global_position
