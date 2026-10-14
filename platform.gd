extends StaticBody3D
@export var plat_col: CollisionShape3D
@export var area: Area3D
signal ledge_grab
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	plat_col.disabled=true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not plat_col.disabled and area.get_overlapping_bodies().size() == 0 :
		plat_col.disabled = true
	
	pass

func _on_ledge_grab_left_body_exited(body: Node3D) -> void:
	ledge_grab.emit(body.name,position)
	pass # Replace with function body.


func _on_ledge_grab_right_body_exited(body: Node3D) -> void:
	ledge_grab.emit(body.name, position)
	pass # Replace with function body.





#func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("ENTERED", body.get_groups())
	#if body.is_in_group("player"):
			#print(body.global_position.y, " ", global_position.y)
			#if body.global_position.y > global_position.y:
				#print("enabling platorm")
				#plat_col.disabled=false
	#pass # Replace with function body.
##
##
#func _on_area_3d_body_exited(body: Node3D) -> void:
	#if body.is_in_group("player"):
		#if body.global_position.y < global_position.y:
			#plat_col.disabled=true
	#pass # Replace with function body.

#
#func _on_above_body_exited(body: Node3D) -> void:
	#collision_layer = 2
	#pass # Replace with function body.


func _on_bottom_body_entered(body: Node3D) -> void:
	print("disable")
	if body.global_position.y < global_position.y:
		plat_col.disabled = true
	else:
		plat_col.disabled = false
	pass # Replace with function body.


func _on_bottom_body_exited(body: Node3D) -> void:
	#if body.global_position.y > global_position.y:
		#print("enable")
		#plat_col.disabled=false
	#else:
		#plat_col.disabled=true
	plat_col.disabled=not plat_col.disabled
	pass # Replace with function body.
