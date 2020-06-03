extends KinematicBody2D

var state = "idle"

var arrowSpeedBase = 650;
var arrowSpeedMax = 900;
var arrowAcc = 400;
var arrowSpeed = arrowSpeedBase;

var player;
onready var playerRaycast = $PlayerCheck
onready var collisionCheck = $Collision

var maxDistance;


var pullSpeedBase = 800;
var pullSpeedMax = 1200;
var pullSpeed = pullSpeedBase;
var pullAcc = 200;

export var timeoutReset : float = 3
var timeout = timeoutReset;

onready var offset = global_position;

var found_player = false

onready var gun = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	maxDistance = abs(playerRaycast.cast_to.x)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
#	global_rotation = atan2(global_position.y - get_global_mouse_position().y,global_position.x - get_global_mouse_position().x )
	
	match(state):
		"shoot":
			shoot(delta)
			found_player = false
			timeout -= delta
		"hit":
			returnHookshot(delta)
			pass
	
	if(timeout <= 0):
		return_arrow()
		timeout = timeoutReset
	
	
	playerRaycast.look_at(player.global_position)
	pass

func shoot(delta):
#	print(rad2deg(angle))
#	print(self)
	move_and_slide(Vector2(cos(global_rotation), sin(global_rotation)) * arrowSpeed)
	if(collisionCheck.get_overlapping_bodies()):
#		var col = wallRaycast.get_collider()
		if not( player in collisionCheck.get_overlapping_bodies()):
			state="hit"
	
	if arrowSpeed <= arrowSpeedMax:
		arrowSpeed = arrowSpeed + arrowAcc * delta;
	if arrowSpeed > arrowSpeedMax:
		arrowSpeed = arrowSpeedMax;
#	print()
	
	pass

func returnHookshot(delta):
#	print("trying to return")
	var playerPos = player.global_position;
#	var pos = global_position
	playerRaycast.force_update_transform()
	playerRaycast.force_raycast_update()
	
	
	
	if(playerRaycast.is_colliding() and playerRaycast.get_collider() == player and player.state != "roll"):
		var playerDir = atan2(global_position.y - player.global_position.y, global_position.x - player.global_position.x)
		playerDir = Vector2(cos(playerDir), sin(playerDir))
		
		player.move_and_slide(playerDir * pullSpeed)
		pullSpeed += pullAcc * delta
		if(pullSpeed > pullSpeedMax): pullSpeed = pullSpeedMax
		
		player.state="hookshot"
		found_player = true;
		
		if( (player.global_position - global_position).length() < 8):
			
			pullSpeed = pullSpeedBase;
			
			return_arrow();
			
			if pullSpeed - pullSpeedBase >= 0.5 * pullSpeedMax - pullSpeedBase:
				singleton.rpc("shakeHeavy")
			else:
				singleton.rpc("shake")
		
	elif(found_player):
		player.state = "move"

func init_shoot():
	state = "shoot"
	var previousPos = global_position
	var previousRot = global_rotation
	var new_parent = get_tree().get_root().get_node('Level')
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = previousPos
	global_rotation = previousRot
	arrowSpeed = arrowSpeedBase;

func return_arrow() -> void:
	get_parent().remove_child(self)
	gun.add_child(self)
	position = Vector2(8,0)
	rotation = 0
	state = "idle"
	pullSpeed = pullSpeedBase;
	player.state = "move"
