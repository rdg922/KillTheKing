extends Node2D


export var weight = 0;
var type = "sword"
var state = "idle"  #setget state_change

var flip_on_rotation = false;
var automatic = false;


onready var swing = preload("res://objects/swing.tscn")
onready var tween = $Tween
onready var timer = $Timer

var swingInst;

onready var start_rot = get_parent().rotation;
var end_rot;

export var swing_duration : float = .1;
export var swing_angle : float = 25
export var swing_hide_sword : float = .1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if(state != "idle"):
		if(len($Collision.get_overlapping_bodies()) > 0 and not $Collision.get_overlapping_bodies()[0].is_in_group("player")):
			tween.stop_all()
			state="stuck"
			$Sprite.show()
			print("colliding")
			$AnimationPlayer.play("cannot_swing")
			pass
	if(state == "stuck"):
		if(len($Collision.get_overlapping_bodies()) >= 0):
			tween.interpolate_property(get_parent(), "rotation", get_parent().rotation, start_rot, 0.05, Tween.TRANS_ELASTIC, Tween.EASE_IN)
			tween.start()
			$Sprite.show()
			get_parent().get_parent().state = "sword_stuck"
		pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
sync func init_shoot():

	if(state=="swing"):
		return
	if(state=="idle"):
		tween.interpolate_property(get_parent(), "rotation", get_parent().rotation, get_parent().rotation + deg2rad(180-swing_angle), swing_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		start_rot = get_parent().rotation
		state = "swing"
		end_rot = get_parent().rotation + deg2rad(180)
#		$Sprite.hide()
	else:
#		$Sprite.show()
		pass
	pass
	

#func state_change(new_state):
#	if(new_state == "end-swing"):
#		$Sprite.show()
#		tween.interpolate_property(get_parent(), "rotation", get_parent().rotation, get_parent().rotation + deg2rad(180), swing_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#		state="end-swing"
func _on_Tween_tween_completed(object, key):
	
	if(state == "swing"):
		get_parent().rotation = end_rot
		swingInst = swing.instance()
		get_tree().get_root().add_child(swingInst)
		swingInst.position = global_position
		swingInst.rotation = end_rot
		swingInst.parent = self
		swingInst.get_node("AnimatedSprite").frame = 0
		timer.start(swing_hide_sword)
		$Sprite.hide()
	
	elif(state == "end-swing"):
		state="idle"
		get_parent().get_parent().state = "move"
	elif(state=="stuck"):
		state="idle"
		get_parent().get_parent().state = "move"

	pass # Replace with function body.


func _on_Timer_timeout():
	$Sprite.show()
	tween.interpolate_property(get_parent(), "rotation", start_rot + deg2rad(180+swing_angle), start_rot + deg2rad(360), swing_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	state="end-swing"
	pass # Replace with function body.
