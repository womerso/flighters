extends CharacterBody3D

@export var pivot: Node3D
@export var hitbox: CollisionShape3D
@export var anim_tree: AnimationTree

const SPEED = 10.0
const JUMP_VELOCITY = 10
const W_ATTACK_VEL = 23
const ATTACK_LAG = 20
const GRAVITY = Vector3(0,-20,0)
const MAX_JUMP = 2
var jump_count = 0
var attacking = false
var attack_count = 0;
var attack_buffer = []
var attack_lag = 0
var special_type = ""
var in_special = false
var is_hanging = false
var special_lag = 0
signal connect
var crouched = true
signal ledge
signal end_ledge
signal attack
signal up_n
signal down_n
signal up_b
signal end_up_b
signal die
signal side_n
signal animate
signal end_jump
signal end_attack
signal move_right
var idle = false
var jump = false
var was_on_floor = false
var double_jump = false
var landed =false
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
		end_jump.emit()
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMP:
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
	if Input.is_action_just_pressed("right") or Input.is_action_just_pressed("left"):
		move_right.emit()
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
	#print(input_dir)
	if direction and not attacking and abs(input_dir.x) > 0.2:
		
		var move_dir := transform.basis.x * input_dir.x
		if is_hanging:
			is_hanging = false
			end_ledge.emit()
		
		if input_dir.y > .5:
			idle = false
			velocity.x = move_dir.x * SPEED * .5
		else:
			idle = false
			velocity.x = move_dir.x * SPEED
		
		
		pivot.rotation.y = 3*PI/2 if input_dir.x < 0 else PI/2
	elif direction and not attacking and abs(input_dir.x) < 2:
		crouched =true

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if input_dir.y > 0 and not is_on_floor():
			velocity +=  GRAVITY * delta
	if velocity.x == 0 and not attacking:
		idle = true
	if Input.is_action_just_pressed("attack") and not in_special: 
		
			print(input_dir)
			if input_dir.y < 0:
				up_n.emit(-1)
			else:
				if attack_lag < 50:
					print("swing")
					attacking = true
					if attack_count < 3:
						attack_count+=1
					else:
						attack_count = 1
					
					anim_tree.set("parameters/conditions/attack_%d" % attack_count, attacking)
					attack_lag = 45
				
	if Input.is_action_just_pressed("special") and not in_special:
		in_special = true
		special_lag = 60
		if input_dir.y < 0:
			attacking=true
			
			special_type = "UP"
			velocity.y = JUMP_VELOCITY * 2
			up_b.emit()

			
			
	
	move_and_slide()
	animate.emit(Vector2(input_dir.x, input_dir.y))
	was_on_floor = is_on_floor()

	if special_lag > 0:
		special_lag-=1
	if special_lag ==0 and in_special:
		if special_type == "UP":
			end_up_b.emit()
	if attack_lag > 0:
		attack_lag-=1
	if attack_lag < 20:
		anim_tree.set("parameters/conditions/attack_%d" % attack_count , false)
	if attack_lag == 0:
		attacking = false
		attack_count = 0
		anim_tree.set("parameters/conditions/attack_1" , false)
		
		
	anim_tree.set("parameters/conditions/is_idle", idle)
	anim_tree.set("parameters/conditions/is_moving", not idle)


	anim_tree.set("parameters/conditions/double_jump", double_jump)
	anim_tree.set("parameters/conditions/is_jump", jump)
	
	anim_tree.set("parameters/conditions/landed", not jump)
	anim_tree.set("parameters/conditions/crouch_move", crouched and not idle)
	print(attack_count)
	
func _on_attack() -> void:
	pass # Replace with function body.






func _on_platform_ledge_grab(nme,pos) -> void:
	if nme == name:
		print("HANGD")
		ledge.emit()
		is_hanging = true
		position.y = pos.y - hitbox.shape.height
	pass # Replace with function body.
