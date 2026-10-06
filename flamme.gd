extends CharacterBody3D

@export var pivot: Node3D
@export var model: Node3D
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
signal crouched
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
signal jump
signal end_jump
signal end_attack
signal move_right
signal idle
var was_on_floor = false
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
		end_jump.emit()
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMP:
		jump.emit()
		jump_count+=1
		if jump_count == MAX_JUMP:
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
			velocity.x = move_dir.x * SPEED * .5
		else:
			velocity.x = move_dir.x * SPEED
		
		
		pivot.rotation.y = 3*PI/2 if input_dir.x < 0 else PI/2
	elif direction and not attacking and abs(input_dir.x) < 2:
		crouched.emit()

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if input_dir.y > 0 and not is_on_floor():
			velocity +=  GRAVITY * delta
	if velocity.x == 0 and not attacking:
		idle.emit()
	if Input.is_action_just_pressed("attack") and not in_special: 
		
			print(input_dir)
			if input_dir.y < 0:
				up_n.emit(-1)
			else:
				if not attacking:
					print("swing")
					attacking = true
					if "Sword" in model.get_anim_state() and attack_count < 3:
						attack_count += 1
					else:
						attack_count = 1
					attack.emit(attack_count)
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
	if  attack_lag < 30 and attacking:
		attacking=not attacking
	if attack_lag == 0:
		attacking = false
		end_attack.emit()
		

func _on_attack() -> void:
	pass # Replace with function body.


func _on_male_body_attack_finish() -> void:
	print(attack_lag)
	attacking = false
	pass # Replace with function body.


func _on_male_body_connect(name) -> void:
	if attacking:
		connect.emit(name)
	pass # Replace with function body.


func _on_platform_ledge_grab(nme) -> void:
	if nme == name:
		ledge.emit()
		is_hanging = true
	pass # Replace with function body.
