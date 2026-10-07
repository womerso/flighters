extends StaticBody3D
@export var platform_box: Area3D
signal ledge_grab
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func is_player_above(body: Node3D):
	return platform_box.get_overlapping_bodies()
func _on_ledge_grab_left_body_exited(body: Node3D) -> void:
	ledge_grab.emit(body.name,position)
	pass # Replace with function body.


func _on_ledge_grab_right_body_exited(body: Node3D) -> void:
	ledge_grab.emit(body.name, position)
	pass # Replace with function body.





#func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("BELOW")
	#if body.position < position:
		#collision_layer = 2
	#pass # Replace with function body.
#
#
#func _on_area_3d_body_exited(body: Node3D) -> void:
	#print("ABOVE")
	#if body.position > position:
		#collision_layer = 1
	#pass # Replace with function body.

#
#func _on_above_body_exited(body: Node3D) -> void:
	#collision_layer = 2
	#pass # Replace with function body.
