extends StaticBody3D

var is_attacking
var W_ATTACK_ACCEL = 25
var rot_vel = 0
var init_rot
var traveled_rot = 0
var sign = 1
var init_position
var modify = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_attacking = false
	init_rot = rotation
	init_position = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_attacking:
		rot_vel = sign* W_ATTACK_ACCEL* delta * modify
		rotate(basis.y.normalized(), rot_vel)
		traveled_rot += rot_vel
		if traveled_rot <= 0 and sign < 0:
			print(init_rot.y - rotation_degrees.y)
			is_attacking = false
			#rotation = init_rot
			#position = init_position
			sign = 1
	if abs(init_rot.y - rotation.y) > 1.74:
			sign = -1
		


func _on_flamme_attack() -> void:
	is_attacking = true
	sign = 1
	
	print("ATTTTACCCKKKK")
	pass # Replace with function body.


func _on_flamme_down_n() -> void:
	pass # Replace with function body.


func _on_flamme_side_n() -> void:
	pass # Replace with function body.


func _on_flamme_up_n() -> void:
	is_attacking = true
	print("up n")
	modify =-1
	pass # Replace with function body.
