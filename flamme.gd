extends CharacterBody3D
@export var player_id: int
@export var pivot: Node3D
@export var hitbox: CollisionShape3D
#@export var anim_tree: AnimationTree
@export var animations: AnimationPlayer
@export var platforms: Node3D
@onready var hit_part: Node3D = $_impact
@onready var jump_part: Node3D = $d_jump
@onready var neutral_attack: Area3D = $"male_body/Skinned Mesh 0/Neutral"

const SPEED = 10.0
const JUMP_VELOCITY = 18 #Was 12
const W_ATTACK_VEL = 23
const ATTACK_LAG = 20
const GRAVITY = Vector3(0,-25,0)
const MAX_JUMP = 2
const HEIGHT_OFFSET = 0.2
const ROT_SPEED = 2000
signal attack_connect

var midcheck = false
var hit_ticks = 0
var proj_sword: Area3D = null
var knockback: Vector3
var stun = 0
var up_b_vy = 0.0
var slash_effect
var jump_count = 0
var attacking = false
var attack_count = 1
var attack_buffer = []
var attack_lag = 0
var special_type = ""
var in_special = false
var is_hanging = false
var hanging_dir = -1
var hang_pos: float
var iframes = 0
var attack_type = ""
var special_lag = 0
var crouched = false
var up_b
var landing_lag = 0
var idle = false
var jump = false
var was_on_floor = false
var side_kb
var double_jump = false
var combo_window = 0
var landed =false
var special_tick = 0
var neutral_stam = 1
var special_dir: int
var side_charge: float = 0
var needs_respawn = false
var is_jumping_b = false
var respawn_count = 0
var respawn_pos: Vector3
var is_shield = false
var d_scale = 1.0
var maintain_air = false
var smash_charge = 1.0
var total_damage = 0
var flame_floor
var flame_scale = 0.0;
@export var flame_effect: PackedScene
@export var thrown_sword_scene: PackedScene
@onready var held_sword = $"male_body/Skinned Mesh 0/Skeleton3D/BoneAttachment3D/sword_box"
@onready var sword_hitbox = $"male_body/Skinned Mesh 0/Skeleton3D/BoneAttachment3D/sword_box/sword_box"
@onready var skin: MeshInstance3D = $"male_body/Skinned Mesh 0/Skeleton3D/Mesh_0_001"
@export var fire_slash: PackedScene
func _ready():
	set_collision_layer_value(2, false)
	set_collision_layer_value(player_id +8, true)

	set_collision_mask_value(9, false)  
	set_collision_mask_value(10, false)
	var new_texture = load("res://Models/textures/male_skin_%d.png" %( player_id ))
	var current_mat = skin.get_active_material(0)
	
	if current_mat:
		var unique_mat = current_mat.duplicate() as StandardMaterial3D

		unique_mat.albedo_texture = new_texture
		skin.material_override = unique_mat

func get_anim_state():
	return #anim_tree.get("parameters/playback").get_current_node()

func _physics_process(delta: float) -> void:
	# Handle jump.
	if is_on_floor() and in_special and special_type == "UP" :
		#in_special = false	
		pass
		
	if  is_on_floor() and (jump_count != 0 or (in_special and special_type=="UP")):
		jump_count = 0
		jump = false
		double_jump = false

	if Input.is_action_just_pressed("jump_p%d" % player_id) and jump_count < MAX_JUMP and "charge" not in attack_type:
		jump = true
		is_hanging=false
		jump_count+=1
		print("Play Animation")
		animations.play("Jump_Start")
		print(animations.current_animation)
		if jump_count == MAX_JUMP:
			double_jump = true
			
			animations.play("Backflip")
			animations.seek(0.6, true)
			velocity.y = JUMP_VELOCITY * .85 # Shortened Double Jump
			for child in jump_part.get_children():
				print(child)
				child.restart()
		else:
			velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left_p%d" % player_id, "right_p%d" % player_id, "up_p%d" % player_id, "down_p%d" % player_id)
	var direction := (transform.basis * Vector3(input_dir.x, 0, 0)).normalized()
	if direction  and abs(input_dir.x) > 0.2 and landing_lag <1 and not (in_special and (special_type=="SIDE" or special_type=="UP" or special_type == "N")) and not attack_type == "side_charge":
		
		var move_dir := transform.basis.x * input_dir.x
		print(input_dir.y)
		if input_dir.y > .5:
			idle = false
			velocity.x = move_dir.x * SPEED * .5
			crouched = true
			print("Crouch Walk")
			animations.play("Crouch_Walk")
		else:
			idle = false
			if is_hanging and sign(move_dir.x) == hanging_dir:
				print(hitbox.shape.height)
				print(hang_pos)
				position.y = hang_pos + hitbox.shape.height - HEIGHT_OFFSET - 0.15
				print(position.y)
			if (is_on_floor()):
				animations.play("Sprint")
			velocity.x = move_dir.x * SPEED

		
			
			crouched=false
		
		if is_hanging:
			is_hanging = false
			double_jump=false
			jump =false
			pivot.rotation.y = 3*PI/2 if hanging_dir < 0 else PI/2
		else:
			pivot.rotation.y = 3*PI/2 if input_dir.x < 0 else PI/2
		
	elif input_dir and not attacking and abs(input_dir.x) < .2 and input_dir.y > .5:
		print(input_dir)
		crouched =true
		animations.play("Crouch_Idle")
	else:
		crouched= false
		if not (in_special and special_type == "SIDE"):
			velocity.x = move_toward(velocity.x, 0, SPEED)
	if input_dir.y > 0 and not is_on_floor():
			velocity +=  GRAVITY * delta
	if velocity.x == 0 and not attacking and "charge" not in attack_type:
		idle = true
	if Input.is_action_just_pressed("attack_p%d" % player_id) and not in_special and landing_lag < 1: 
		idle = false
		if  is_on_floor():
			if abs(input_dir.x) != 0.0:
				animations.play("forward_smash_charge")
				attack_type = "side_charge"
				attack_lag = -1
			elif abs(input_dir.y) >= 0.3:
				animations.play("up_smash_charge")
				attack_type = "up_charge"
				attack_lag = -1
			else:
				print("attack")
				var c: String = "A"
				if combo_window > 0:
					
					if attack_count == 1:
						c = "A"
					elif attack_count == 2:
						c = "B"
					else:
						c = "C"
					
					
					if attack_count > 2:
						attack_count = 1
					else:
						attack_count+=1
				else:
					attack_count = 1
				animations.play("Sword_Regular_%s" % c)
				slash_effect = fire_slash.instantiate()
				sword_hitbox.add_child(slash_effect)
				attacking = true
				attack_type = "neutral_%d" % attack_count
				attack_lag = 15
				combo_window = 50
				
		else:
			animations.play("air_neutral")
			attacking = true
			attack_lag = 15
			combo_window = 45
			attack_type = "neutral_air"
	if Input.is_action_pressed("attack_p%d" % player_id):
		if smash_charge <= 3:
			smash_charge += 0.03
		
	if Input.is_action_just_released("attack_p%d" % player_id):
		if attack_type == "side_charge":
			attacking = true
			animations.play("forward_smash_end")
			attack_lag = 15
		if attack_type == "up_charge":
			attacking = true
			animations.play("up_smash_end")
			attack_lag = 15
				
	if Input.is_action_just_pressed("special_p%d" % player_id) and not in_special and landing_lag < 1:
		in_special = true
		special_lag = 60
		idle = false
		if input_dir.y < -0.2:
			print("upb")
			attacking=true
			special_lag = 100
			special_type = "UP"
			animations.play("Throw_Up")
			flame_floor = flame_effect.instantiate()
			pivot.add_child(flame_floor)
			flame_scale = 0.0
			flame_floor.get_child(0).get_active_material(0).set_shader_parameter("time", delta)
			attack_type = "up_b"
			up_b = true
		elif input_dir.x != 0:
			print("sidb")
			special_lag = -1
			special_type = "SIDE"
			special_dir = sign(input_dir.x)
			animations.play("side_b_enter")
			attack_type = "side_b"
		else:
			attacking= true
			special_type = "N"
			in_special=true
			animations.play("Spell_Simple_Enter")
			#anim_tree.set("parameters/conditions/end_neutral", false) 
			attack_type = "neutral_b"
			for child in neutral_attack.get_children():
				if child is CollisionShape3D:
					
					child.disabled = false
				if child is GPUParticles3D:
					child.emitting = true
	if Input.is_action_just_released("special_p%d" % player_id):
		print(Input.is_action_just_released("special_p%d" % player_id))
	if (Input.is_action_just_released("special_p%d" % player_id) or neutral_stam <= 0.0) and in_special :
		print("chefck")
		if special_type == "N":
			attacking= false
			in_special = false
			neutral_attack.scale = Vector3(1,1,1)
			animations.play("Spell_Simple_Exit")
			for child in neutral_attack.get_children():
				if child is CollisionShape3D:
					
					child.disabled = true
				if child is GPUParticles3D:
					child.emitting = false
		elif special_type == "SIDE":
			animations.play("side_b_leave")
			pass
	if Input.is_action_pressed("special_p%d" % player_id) and in_special and special_type=="SIDE":
		velocity.x = 0
		side_charge +=0.01
		
	if Input.is_action_just_released("special_p%d" % player_id) and in_special and special_type=="SIDE":
		side_charge = max(1.0, side_charge)
		velocity.x = side_charge * 100 * special_dir
		attacking = true
		special_lag = 30
		side_kb = side_charge
		side_charge = 0

	if not is_on_floor() and not is_hanging:
		velocity +=  GRAVITY * delta
		if stun > 0:
			knockback += GRAVITY * delta
		
	if not is_on_floor() and is_hanging:
		velocity.y = 0
		jump_count = 0
		
	if stun > 0:
		knockback = knockback.lerp(Vector3.ZERO, delta)
		velocity = knockback
	if in_special and special_type == "SIDE":
		attacking = true
		velocity.x = lerp(velocity.x, 0.0, delta * 5.0)
	
	if in_special and up_b and maintain_air:
		velocity.y = -0.1
	move_and_slide()
	if flame_floor:
		flame_scale += delta
		flame_floor.get_child(0).get_active_material(0).set_shader_parameter("time", flame_scale)
	if up_b_vy > 0.0 and is_on_ceiling():
		velocity.y = up_b_vy
		up_b_vy = 0.0  
	was_on_floor = is_on_floor()
	if landing_lag > 0:
		landing_lag-=1
	if iframes > 0:
		iframes-=1
	if special_lag > 0:
		special_lag-=1
		if special_type == "UP":
			if proj_sword != null:
				if not midcheck:
					for body in proj_sword.get_overlapping_bodies():
							_on_sword_box_body_exited(body)
					midcheck = true
				proj_sword.rotation_degrees.z += delta * ROT_SPEED
				proj_sword.position.y = move_toward(proj_sword.position.y , proj_sword.position.y  + JUMP_VELOCITY, 12 * delta)

				if is_jumping_b:
					proj_sword.body_entered.connect(rejoin_sword)
			
					velocity.y += JUMP_VELOCITY * 2
					up_b_vy = velocity.y
					is_jumping_b = false
					maintain_air = false
					
	if special_lag ==0 and in_special:
		if special_type == "UP":
			print("ending")
			up_b = false
			in_special = false
			if proj_sword:
				rejoin_sword(self)
		if special_type == "SIDE":
			in_special = false
	if in_special and special_type == "N":
		hit_ticks += 1
		if hit_ticks % 2 == 0:
			for body in neutral_attack.get_overlapping_bodies():
				attack_connect.emit(body.name,pivot.rotation_degrees.y, 1, 0.1, attack_type)
	
	if attack_lag > 0:
		if not midcheck:
			for body in held_sword.get_overlapping_bodies():
					_on_sword_box_body_exited(body)
			midcheck = true
		attack_lag-=1

	elif attacking and not ( in_special and (special_type == "SIDE" or special_type=="UP")) :

		attacking = false
		attack_type = ""
		midcheck=false
	if combo_window > 0:
		combo_window-=1
		attacking = true
	elif combo_window == 0:
		attack_count = 1
		combo_window = -1
	if in_special:
		special_tick+=1
	else:
		special_tick = 0
	if in_special and special_type == "N":
		neutral_stam -=0.01
		neutral_attack.scale = neutral_stam * Vector3(1,1,1)
	if not in_special and neutral_stam < 1:
		neutral_stam += 0.01
	if respawn_count > 0:
		respawn_count-=1
	elif needs_respawn:
		respawn(respawn_pos)
		needs_respawn = false
	if attack_type == "side_charge" or attack_type == "up_charge" :
		for body in held_sword.get_overlapping_bodies():
				_on_sword_box_body_exited(body)
	
	if in_special and special_type == "UP":
		attacking = true
	if not attacking:
		sword_hitbox.disabled = true
	elif sword_hitbox.disabled:
		sword_hitbox.disabled = false
	if stun > 0:
		stun -=1
	
	if not(not is_on_floor() and not stun > 0 and not is_hanging) and (animations.current_animation == "Jump_air" or animations.current_animation == "Jump_Start" or animations.current_animation == "Backflip"):
		print("changing")
		
		_on_animation_player_animation_finished("Jump_air")
	elif (not is_on_floor() and not stun > 0 and not is_hanging and not attacking ) and (animations.current_animation != "Jump_Start" and animations.current_animation != "Backflip" and animations.current_animation != "Throw_Up"):
		animations.play("Jump_air")
	elif is_on_floor() and animations.current_animation != "Jump_Land" and animations.current_animation != "Spell_Simple_Exit" and animations.current_animation != "Spell_Simple_Enter" and animations.current_animation != "Spell_Simple_Idle" and "smash" not in animations.current_animation:
		if not idle and not crouched and not attacking and not in_special and attack_type == "":
			animations.play("Sprint")
		elif idle and not crouched and not is_hanging and not attacking and not in_special:
			
			animations.play("Idle_A")

	if "Sword_Regular" not in animations.current_animation and sword_hitbox.get_child_count() > 0:
		for child in sword_hitbox.get_children():
			sword_hitbox.remove_child(child)
func land():
	print("land")
	landing_lag = 15
	attack_type = ""
	animations.play("Jump_Land")

func on_hit( y_rot, base_damage, kb_mult, at):
			iframes = 60
			
			print(kb_mult, " ", at)
			total_damage+=base_damage * d_scale
			pivot.rotation_degrees.y = y_rot * -1

			if at == "up_b":
				knockback = Vector3(0.0, 15.0,0.0)
			if at == "side_b":
				knockback = kb_mult * Vector3(12.0, 1.0,0.0)
			if at == "neutral_b":
				knockback = Vector3(0.0, 0.0,0.0)
				iframes = 8
			if at == "neutral_1" or at == "neutral_2":
				iframes = 1
			if at == "neutral_3":
				iframes = 16
				knockback = Vector3(12.0, 3.0,0.0)
			if at == "side_charge":
				iframes = 16
				knockback = Vector3(10 * kb_mult, 2.0 * kb_mult, 0.0)
			if at == "up_charge":
				iframes = 16
				knockback = Vector3(1.0, 10 * kb_mult, 0.0)
			knockback.x *= sign(cos(deg_to_rad(y_rot))) 
			#knockback = (total_damage / 50.0 )*Vector3(sign(cos(deg_to_rad(y_rot))) * base_knockback,1.0, 0.0)
			print(knockback)
			if (abs(knockback.x) > 1.0):
				animations.play("Hit_Knockback")
				pass
			else:
				animations.play("Hit_Chest")
				pass
			for child in hit_part.get_children():
				print(child)
				child.restart()
			stun = 20
func respawn(pos):
	position = Vector3(0.0, pos.y, 0.0)
	velocity = Vector3.ZERO
	total_damage = 0
	pass
	
func _on_sword_box_body_exited(body: Node3D) -> void:
	print(name ," is attempt connect ", body.name)
	if attacking:
		print("connect")
		if attack_type == "side_b":
			side_kb = side_charge
		if attack_type == "side_charge" or attack_type == "up_charge":
			side_kb = smash_charge
		
		attack_connect.emit(body.name,pivot.rotation_degrees.y, 5 + attack_count, side_kb, attack_type)
	pass # Replace with function body.

func execute_throw():
	held_sword.hide() # Make the hand weapon invisible
	
	# Spawn the flying weapon
	var projectile = thrown_sword_scene.instantiate()
	get_tree().root.add_child(projectile) # Add it to the world, not the player
	
	# Snap the flying weapon to the exact position and angle of the hand weapon
	projectile.global_transform = held_sword.global_transform
	
	proj_sword = projectile
	
func _on_flamme_attack_connect(target, y_rot, base_damage, base_knockback, at) -> void:
	print(iframes)
	if target==name:
		if not is_shield and iframes <= 0:
			
			on_hit(y_rot, base_damage, base_knockback, at)
	pass # Replace with function body.


func _on_flamme_2_attack_connect(target, y_rot, base_damage, base_knockback, at) -> void:
	print(iframes)
	if target==name:
		if not is_shield and iframes <= 0:
			on_hit(y_rot, base_damage, base_knockback, at)
	pass # Replace with function body.





func _on_neutral_body_entered(body: Node3D) -> void:
	print("oohjooo")
	attack_connect.emit(body.name,pivot.rotation_degrees.y, 2, 0.1, attack_type)
	pass # Replace with function body.


func _on_platforms_ledge_grab(body,gposition, dir) -> void:
	if body.name == name and position.y + hitbox.shape.get("height") < gposition.y and not up_b:
		print(gposition.y, "  ", position.y )
		hang_pos = gposition.y
		velocity.y = 0
		is_hanging = true
		hanging_dir = dir
	pass # Replace with function body.


func _on_overlay_plane_entered(body,pos) -> void:
	if body.name == name:
		respawn_count = 30
		respawn_pos = pos
		needs_respawn = true
	
	pass # Replace with function body.
func begin_jump():
	print("Jump")
	print(special_lag)
	is_jumping_b = true
	pivot.remove_child(flame_floor)





func rejoin_sword(body: Node3D) -> void:
	print("attempt join")
	print(body.name, " ", name)
	if body.name == name:
		print("correct join")
		held_sword.show()
		get_tree().root.remove_child(proj_sword)
		velocity.y = 0.0;
		maintain_air = true
	proj_sword.queue_free()
	proj_sword = null
	pass # Replace with function body.


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	if anim_name == "Jump_Start":
		animations.play("Jump_air")
	elif anim_name == "Jump_air":
		animations.play("Jump_Land")
	elif anim_name == "Jump_Land":
		animations.play("Idle_A")
	elif anim_name == "Spell_Simple_Enter":
		animations.play("Spell_Simple_Idle")
	elif anim_name == "Spell_Simple_Exit":
		animations.play("Idle_A")
	elif "Sword_Regular" in anim_name:
		for child in sword_hitbox.get_children():
			sword_hitbox.remove_child(child)
	pass # Replace with function body.
