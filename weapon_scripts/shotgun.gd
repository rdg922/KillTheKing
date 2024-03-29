extends Node2D

export var weight = 20;
var flip_on_rotation = true;
var automatic = false;
var type = "gun"


onready var bullet : Resource = singleton.bullet;
onready var spawnPoint : Position2D = $Position2D

var will_shoot = false

export var bulletLife : float = .15;

export var bulletOffsetAngle : float = 20
# Called when the node enters the scene tree for the first time.
func _process(delta):
	
	if(will_shoot && $AnimationPlayer.current_animation != "shoot"):
		
		#3 bullets shot with varying angles
		for i in range(-1, 2):
			var bulletInst : Area2D = bullet.instance()
			get_tree().get_root().get_node("Level").add_child(bulletInst)
			bulletInst.global_position = get_spawn_point()
			bulletInst.global_rotation = global_rotation - (i * deg2rad(bulletOffsetAngle)) # Offset from -angle, 0, +angle 
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
