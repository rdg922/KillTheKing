extends KinematicBody2D

export var health : int = 10 setget new_health
export var speed : float = 20

var knockback_dir = Vector2()
var knockback_speed = 250;
var knockback_reset = .2;
var knockback_timer;


var state = "idle"

onready var sprite = $AnimatedSprite
onready var player_radius = $PlayerFoundRadius
onready var regular_material = "res://scripts/anti-jitter.tres"
onready var healhbar = $EnemyHealthbar


var player_target = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match(state):
		"idle":
			pass
		"walk":
			if(player_target == null): start_walk_state()
			move_and_slide((player_target.global_position - global_position).normalized() * speed)
			
			
			set_sprite_flip(player_target.global_position)
		"hit":
			move_and_slide(knockback_dir * knockback_speed)
			
			knockback_timer -= delta;
			
			if(knockback_timer <= 0):
				state = "move"
				self.modulate.a = 1
				sprite.material = load(regular_material)

			pass
	pass

func _on_SearchRadius_body_entered(body):
	
	print(body)
	
	player_target = get_target()
	if(player_target != null):
		start_walk_state()
		
		
	pass # Replace with function body.

func start_idle_state():
	sprite.play("idle")
	state = "idle"
	pass

func start_walk_state():
	state = "walk"

func walk():
	pass

sync func change_health(amount):
	health += amount
	$EnemyHealthbar.health = health

func get_target() -> KinematicBody2D:
	var players = player_radius.get_overlapping_bodies()
	var target;
	
	for player in players:

		if not player.is_in_group("player"):
			players.erase(player)
			continue
		
		if target == null:
			target = player
		
		if player.health < target.health:
			target = player
	
	return target

func set_sprite_flip(pos: Vector2):
	if pos.x - global_position.x > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func new_health(value):
	healhbar.health = value
	pass
