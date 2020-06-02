extends Node2D


export var weight = 0;
var type = "sword"
var state = "idle" # rotation of parent will change
onready var hand = get_parent()


var flip_on_rotation = false;
var automatic = false;


onready var swing = preload("res://objects/swing.tscn")
onready var tween = $Tween
onready var timer = $Timer


var anchor_angle;
var weapon_angle_offset : float = 30;
var weapon_side : String = "left"
var swingInst;


export var swing_duration : float = .02;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):

	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
sync func init_shoot():
	
	anchor_angle = hand.get_rotation()
	
	var start_angle = anchor_angle;
	var end_angle = anchor_angle;
	if(weapon_side == "left"):
		start_angle -= deg2rad(weapon_angle_offset)
		end_angle += deg2rad(weapon_angle_offset)
	else:
		start_angle += deg2rad(weapon_angle_offset)
		end_angle -= deg2rad(weapon_angle_offset)
	
	tween.interpolate_property(hand, "rotation", start_angle, end_angle, swing_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	state="swing"
	
	pass
	


func _on_Tween_tween_completed(object, key):
	swingInst = swing.instance();
	swingInst.get_node("AnimatedSprite").frame = 0
#	get_tree().get_root().add_child(swingInst)
	add_child(swingInst)
	
	
	if(weapon_side == "left"):
		weapon_side == "right"
	elif(weapon_side == "right"):
		weapon_side == "left"
	
	state="idle"
	
	pass # Replace with function body.
