extends KinematicBody2D

const SPEED := 200;

var speed := 0.0;

const acceleration := 1000;
const maxSpeed := 220;
const deAcc := 1600;
var state = "move";


onready var camera := $Camera2D;
onready var sprite := $AnimatedSprite
onready var inventory_node : Node2D = get_node("Inventory")
onready var inventory : Array = inventory_node.get_children()
onready var sprite_scale : Vector2 = sprite.scale

onready var collision_shape : CollisionShape2D = $CollisionShape2D

var dir := Vector2();

const rollTime := 0.25;
var rollTimer := 0.0;

const rollSpeedBase := 400;
const rollSpeedDeacc := 300;
const rollSpeedMin := SPEED;
var rollSpeed = rollSpeedBase;

const rollWait := 0.35;
var rollWaitTimer := 0.0

var current_hand := 0;
var hand_rot := 0.0;

var knockback_dir := Vector2()
const knockback_speed := 250;
const knockback_reset := .2;
const speed_when_hit := 100;
var knockback_timer := 0.0;

const fall_reset := 1;
var fall_timer := 0.0;

var health := 25;

puppet var slave_position := Vector2()
puppet var slave_movement := Vector2()
puppet var slave_rotation := 0.0;
puppet var slave_animation := "idle";
puppet var slave_state := "move"
export var is_dummy := false

var last_valid_position := Vector2()

var last_movement_sent = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	rpc("set_health", health)
	
	if(is_dummy):
		rpc("set_health", 1000);
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	
	
	if(is_network_master()):
		match(state):
			("move"):
				
				
				
				#Move
				var xdir = int(Input.is_action_pressed('right')) - int(Input.is_action_pressed("left"))
				var ydir = int(Input.is_action_pressed('down')) - int(Input.is_action_pressed("up"))
				
				dir = Vector2(xdir, ydir)
				dir = dir.normalized()
				
				if(is_dummy):
					dir = Vector2()
				
				move(dir, delta)
								
				if(Input.is_action_just_pressed("roll") and not is_dummy):
					state="roll"
					rollTimer = rollTime;
					rollSpeed = rollSpeedBase;

#					rpc("set_material", dash_material)

				can_switch()
				can_shoot()
				update_valid_position()
				enable_void_collision()
				
			("roll"):
				
				rollSpeed -= rollSpeedDeacc * delta
				if(rollSpeed < SPEED): rollSpeed = SPEED
				
				var weight = get_current_weight(current_hand)
					
				move_and_slide(dir * rollSpeed); #Weight independent
				
				
				
				if(rollTimer <= 0):
					state="post_roll"
#					rpc("set_material", post_roll_material)
					rollWaitTimer = rollWait
				
				rollTimer -= delta
				disable_void_collision()
				
				
				
			("hookshot"):
				sprite.animation = "idle"
				sprite.frame = 0
				can_shoot()
				can_switch()
				disable_void_collision()
			
			
			("post_roll"):
				rollWaitTimer -= delta
				
				var xdir = int(Input.is_action_pressed('right')) - int(Input.is_action_pressed("left"))
				var ydir = int(Input.is_action_pressed('down')) - int(Input.is_action_pressed("up"))
				
				dir = Vector2(xdir, ydir)
				dir = dir.normalized()
				
				var weight = get_current_weight(current_hand)
				
				move_and_slide(dir * (SPEED - weight) * 0.5)
				sprite.speed_scale = 1
				
				if(rollWaitTimer <= 0):
					state="move"
					sprite.speed_scale = 2
#					rpc("set_material", regular_material)
				
				sprite.scale.x = -sprite_scale.x * sign(global_position.x - get_global_mouse_position().x)
				
				can_switch()
				can_shoot()
				update_valid_position()
				enable_void_collision()
			
			("hit"):
				move_and_slide(knockback_dir * knockback_speed)
				
				knockback_timer -= delta;
				
				#Material change happens in bullet
				var xdir = int(Input.is_action_pressed('right')) - int(Input.is_action_pressed("left"))
				var ydir = int(Input.is_action_pressed('down')) - int(Input.is_action_pressed("up"))
				
				dir = Vector2(xdir, ydir)
				dir = dir.normalized()
				
				if(!is_dummy):
					move_and_slide(dir * speed_when_hit) #Player can move
				
				if(knockback_timer <= 0):
					state = "move"
					self.modulate.a = 1
				
				can_shoot()
				can_switch()
				update_valid_position()
#				enable_void_collision()
				
			("fell"):
				
				fall_timer -= delta
				if fall_timer <= 0:
					state = "move"
				
				
				pass
		check_void()
		sprite.material = singleton.state_materials[state]
		handle_camera();
		handle_hand();
		
		rset_unreliable('slave_position', position)
		rset_unreliable('slave_rotation', hand_rot)
		
		if(last_movement_sent != dir):
			rset('slave_movement', dir)
			last_movement_sent = dir
		
		rset_unreliable('slave_state', state)
		
		camera.current = true
#		print(state)
		
	else:
		position = slave_position
		camera.current = false
		
		inventory_node.rotation = slave_rotation
		if($AnimatedSprite.animation != slave_animation):
			$AnimatedSprite.play(slave_animation)

		var weight = get_current_weight(current_hand)
		
#		print(slave_state, singleton.state_materials)
		sprite.material = singleton.state_materials[slave_state]
#		print(sprite.material)
				
		
		$AnimatedSprite.flip_h = bool(cos(slave_rotation) < 0) 
		for gun in inventory:
			if(gun.flip_on_rotation):
				gun.get_node("Sprite").flip_v = bool(cos(slave_rotation) < 0)
		
			
		
		pass
	
	if get_tree().is_network_server() and not is_dummy:
		Network.update_position(int(name), position)
		 
		pass
	pass

sync func change_health(amount) -> void:
	health += amount
	$Healthbar.health = health 

sync func set_health(amount) -> void:
	$Healthbar.health = amount
	health = amount

sync func set_material(mat) -> void:
	$AnimatedSprite.material = load(mat);
	pass

func move(dir: Vector2, delta: float, decrease := 0) -> void:
	var weight = get_current_weight(current_hand)

	
	if(dir != Vector2(0,0)):
		
		if(sprite.scale.x/sprite_scale.x - dir.x == 2 || sprite.scale.x/sprite_scale.x - dir.x == -2):
			sprite.animation = "run_backwards"
			rset_unreliable("slave_animation", "run_backwards")
		else:
			sprite.animation = "run"
			rset_unreliable("slave_animation", "run")
		
		speed = speed + acceleration * delta
	else:
		sprite.animation = "idle"
		rset_unreliable("slave_animation", "idle")
		speed -= deAcc * delta
		
		
	if(speed < 0):
		speed = 0;
	if(speed > maxSpeed):
		speed = maxSpeed
	
#	print(speed)
	sprite.scale.x = -sprite_scale.x * sign(global_position.x - get_global_mouse_position().x)	
	move_and_slide(dir * max(0, (speed - weight)) )
	

func can_shoot() -> void:
	
	if(is_dummy):
		return
	
	var gun = inventory[current_hand];
	
	if(Input.is_action_just_pressed("left_click") || (Input.is_action_pressed("left_click") and gun.automatic == true)):
		if(gun.type == "sword" or (not gun.get_node("Collision").get_overlapping_bodies() and gun.type == "gun") ):
			gun.rpc("init_shoot");


func handle_hand() -> void:
	if(is_dummy):
		return
	
	hand_rot = TAU/2 + atan2(global_position.y - get_global_mouse_position().y, global_position.x - get_global_mouse_position().x)
	
	
	var weapon = inventory[current_hand]
	
	inventory_node.rotation = hand_rot

	for weapon in inventory:
		
		if(weapon.flip_on_rotation):
			weapon.get_node("Sprite").flip_v = bool(cos(hand_rot) < 0)
		pass

#	leftHand.get_node("Gun/Sprite").flip_v = bool(cos(rightHand.rotation) < 0)
	pass

func handle_camera() -> void:
	if(is_dummy):
		return
	var mousePos = get_global_mouse_position();
	var camPos = camera.global_position;
	
	camera.global_position = (mousePos - global_position)/2.5 + global_position
	pass

func can_switch() -> void:
	if(is_dummy):
		return
	if(Input.is_action_just_pressed("right_click")):
		current_hand+=1
		if(current_hand == len(inventory)):
			current_hand = 0;
		rpc("set_hand", current_hand)
	
	if(Input.is_action_just_pressed("inv_1")):
		current_hand = 0
		rpc("set_hand", current_hand)
	elif(Input.is_action_just_pressed("inv_2")):
		current_hand = 1
		rpc("set_hand", current_hand)
	elif(Input.is_action_just_pressed("inv_3")):
		current_hand = 2
		rpc("set_hand", current_hand)
	elif(Input.is_action_just_pressed("inv_4")):
		current_hand = 3
		rpc("set_hand", current_hand)
sync func set_hand(hand: int) -> void:
	for gun in inventory:
		if(gun == inventory[hand]):
			gun.show()
		else:
			gun.hide();
		

func put_in_void() -> void:
	print(state)
	if(state == "roll" || state == "hookshot"):
		return
	else:
		state="fell"
		fall_timer = fall_reset
		position = last_valid_position
		damage()
		pass

func update_valid_position() -> void:
	var bodies = $Area2D.get_overlapping_bodies() 
	if(len(bodies) > 0):
		for body in bodies:
			if body.is_in_group("void"):
				return
	last_valid_position = position

func get_current_weight(hand: int) -> int:
	return inventory[hand].weight;


func init(pos, is_slave) -> void:
	position = pos 
	if(is_slave):
		$Camera2D.current = false


func check_void():
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("void"):
			put_in_void()

sync func damage(damage := 1, knockback := Vector2()) -> void:
	knockback_timer = knockback_reset
	state = "hit"
	sprite.material = singleton.state_materials["hit"]
	knockback_dir = knockback;
#	rpc("change_health", -damage)
	return

sync func disable_void_collision() -> void:
	set_collision_mask_bit(10, false)
	return

func enable_void_collision() -> void:
	set_collision_mask_bit(10, true)
	return
