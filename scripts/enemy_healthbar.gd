extends Node2D

onready var health : int = get_parent().health setget change_health

onready var health_bar = $HealthBar
onready var background_bar = $BackgroundBar;
onready var tween = $Tween

const time_per_damage_point = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$HealthBar.max_value = health * 100
	background_bar.max_value = health * 100
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func change_health(new_health):

	tween.interpolate_property(background_bar, "value", health_bar.value, new_health * 100, time_per_damage_point, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	
	$HealthBar.value = new_health * 100
	
	if(new_health <= 0):
		get_parent().queue_free()
