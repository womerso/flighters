extends CharacterBody3D

@export var pivot: Node3D
@export var hitbox: CollisionShape3D
@export var anim_tree: AnimationTree
@export var platforms: Node3D
@onready var hit_part: Node3D = $_impact
const SPEED = 10.0
const JUMP_VELOCITY = 12
const W_ATTACK_VEL = 23
const ATTACK_LAG = 20
const GRAVITY = Vector3(0,-20,0)
const MAX_JUMP = 2

signal attack_connect


var jump_count = 0
var attacking = false
var attack_count = 1
var attack_buffer = []
var attack_lag = 0
var special_type = ""
var in_special = false
var is_hanging = false
var special_lag = 0
var crouched = false
var up_b
var landing_lag = 0
var idle = false
var jump = false
var was_on_floor = false
var double_jump = false
var combo_window = 0
var landed =false
var knockback: Vector3
var stun = 0
var is_shield = false
var d_scale = 1.0
var total_damage = 0
func get_anim_state():
	return anim_tree.get("parameters/playback").get_current_node()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor() and not is_hanging:
		velocity +=  GRAVITY * delta
		
	if not is_on_floor() and is_hanging:
		velocity.y = 0
		

	# Handle jump.
	if is_on_floor() and in_special:
		in_special = false
	if  is_on_floor() and (jump_count != 0 or (in_special and special_type=="UP")):
		jump_count = 0
		jump = false
		double_jump = false
		landing_lag = 15
	if Input.is_action_just_pressed("p2_jump") and jump_count < MAX_JUMP and stun < 1:
		jump = true
		jump_count+=1
		if jump_count == MAX_JUMP:
			anim_tree.set("parameters/BackFlip/TimeSeek/seek_request", 0.6)
			double_jump = true
			velocity.y = JUMP_VELOCITY * 1.5
		else:
			velocity.y = JUMP_VELOCITY
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("p2_left", "p2_right", "p2_up", "p2_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()

	if direction and not attacking and abs(input_dir.x) > 0.2 and landing_lag <1 and stun < 1:
		
		var move_dir := transform.basis.x * input_dir.x
		if is_hanging:
			is_hanging = false
		
		if input_dir.y > .5:
			idle = false
			velocity.x = move_dir.x * SPEED * .5
			crouched = true
		else:
			idle = false
			velocity.x = move_dir.x * SPEED
			
			crouched=false
		
		
		pivot.rotation.y = 3*PI/2 if input_dir.x < 0 else PI/2
		
	elif direction and not attacking and abs(input_dir.x) < .2 and input_dir.y > .5 and stun <1:
		crouched =true
	else:
		crouched= false
		if stun < 1:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	if input_dir.y > 0 and not is_on_floor():
			velocity +=  GRAVITY * delta
	if velocity.x == 0 and not attacking:
		idle = true
	if Input.is_action_just_pressed("p2_attack") and not in_special and landing_lag < 1: 
		
		
		if combo_window > 0:
			anim_tree.set("parameters/conditions/attack_%d" % attack_count, false)
			if attack_count > 2:
				attack_count = 1
			else:
				attack_count+=1
		
		anim_tree.set("parameters/conditions/attack_%d" % attack_count, true)
		attacking = true
		attack_lag = 15
		combo_window = 45
			#if input_dir.y < 0:
				#up_n.emit(-1)
			#else:
				#if not attacking:
					#print("swing")
					#attacking = true
					#if attack_count < 3:
						#attack_count+=1
					#else:
						#attack_count = 1
					#
					#anim_tree.set("parameters/conditions/attack_%d" % attack_count, attacking)
					#attack_lag = 45
				
	if Input.is_action_just_pressed("p2_special") and not in_special and landing_lag < 1:
		in_special = true
		special_lag = 60
		if input_dir.y < 0:
			attacking=true
			
			special_type = "UP"
			velocity.y = JUMP_VELOCITY * 2
			up_b = true
			
	if stun > 0:
		velocity = velocity + knockback	
		knockback.x = move_toward(knockback.x, 0, delta)
		knockback.y = move_toward(knockback.y, 0, delta)
	move_and_slide()
	was_on_floor = is_on_floor()
	if landing_lag > 0:
		landing_lag-=1
	if special_lag > 0:
		special_lag-=1
	if special_lag ==0 and in_special:
		if special_type == "UP":
			up_b = false
	if attack_lag > 0:
		attack_lag-=1
		
	elif attacking:
		attacking = false
		anim_tree.set("parameters/conditions/attack_%d" % attack_count, false)
	if combo_window > 0:
		combo_window-=1
	elif combo_window == 0:
		anim_tree.set("parameters/conditions/attack_%d" % attack_count, false)
		attack_count = 1
		combo_window = -1
	if stun > 0:
		stun -=1
	#if attack_lag < 40 and attacking:
		#attacking = not attacking
	#if attack_lag == 0:
		#attacking = false
		#attack_count = 0
		#anim_tree.set("parameters/conditions/attack_1" , false)
		#
		
	anim_tree.set("parameters/conditions/is_idle", idle and not crouched)
	anim_tree.set("parameters/conditions/is_moving", not idle and not crouched)
	anim_tree.set("parameters/conditions/is_crouched", crouched and idle)
	anim_tree.set("parameters/conditions/crouch_move", crouched and not idle)
	
	anim_tree.set("parameters/conditions/double_jump", double_jump)
	anim_tree.set("parameters/conditions/up_b", up_b)
	anim_tree.set("parameters/conditions/is_jump", jump)
	anim_tree.set("parameters/conditions/in_air", not is_on_floor())
	
	anim_tree.set("parameters/conditions/end_neutral", not in_special and special_type == "n")
	
	anim_tree.set("parameters/conditions/landed", not jump and is_on_floor())
	


func _on_sword_box_body_exited(body: Node3D) -> void:
	if attacking:
		
		attack_connect.emit(body.name,pivot.rotation_degrees.y, 11, 0.01 if attack_count < 3 else 1.5)
	pass # Replace with function body.
	pass # Replace with function body.


func on_hit( y_rot, base_damage: float, base_knockback):
			total_damage+=base_damage * d_scale
			pivot.rotation_degrees.y = y_rot * -1
			print(total_damage)
			knockback = base_knockback * Vector3(sign(cos(deg_to_rad(y_rot))) * total_damage / 50,0, 0.0)
			print(knockback)
			if (abs(knockback.x) > 1.0):
				anim_tree.get("parameters/playback").start("Hit_Knockback")
			else:
				anim_tree.get("parameters/playback").start("Hit_Chest")
			for child in hit_part.get_children():
				print(child)
				child.restart()
			stun = 10

func _on_flamme_attack_connect(target, y_rot, base_damage: float, base_knockback) -> void:
	
	# Flamme 2 being hit
	print(target, ' ', name, ' ', y_rot, ' ', pivot.rotation_degrees.y)
	if target== name:
		if not is_shield:
			on_hit(y_rot, base_damage, base_knockback)
	pass # Replace with function body.
