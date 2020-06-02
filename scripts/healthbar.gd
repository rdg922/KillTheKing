extends Node2D


#Default Hud Position
onready var default_position : Vector2 = position
onready var aboveBar = $Healthbar
onready var backgroundBar = $Backgroundbar

var health setget change_health

# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.



func _process(delta):
	if($Area2D.get_overlapping_areas()):
#		bar.position = Vector2(default_position.x, -default_position.y)
#	else:
#		bar.position = default_position
		modulate.a = .25
	else:
		modulate.a = 1
	pass

func change_health(health):
	
	$Label.text = str(health)
	
	pass
