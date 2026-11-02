extends StaticBody3D
@export var plat_col: CollisionShape3D
@export var area: Area3D
signal ledge_grab
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func _on_ledge_grab_left_body_exited(body: Node3D) -> void:
	print("ledge?")
	ledge_grab.emit(body, position,1)
	pass # Replace with function body.


func _on_ledge_grab_right_body_exited(body: Node3D) -> void:
	print("Pos: ", position.y)
	print("GPos: ", global_position.y)
	ledge_grab.emit(body, position,-1)
	pass # Replace with function body.



func _on_bottom_body_entered(body: Node3D) -> void:
	print("disable")
	if body.global_position.y < global_position.y:
		print("removing Collision - enter - %s" % body.name)
		add_collision_exception_with(body)



func _on_bottom_body_exited(body: Node3D) -> void:

	
	if body in get_collision_exceptions():
		print("adding collision - exit - %s" % body.name)
		remove_collision_exception_with(body)
