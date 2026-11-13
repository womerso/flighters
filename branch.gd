extends StaticBody3D
signal ledge_grab
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	pass

func _on_ledge_grab_body_exited(body: Node3D) -> void:
	print(sin(global_rotation_degrees.y))
	ledge_grab.emit(body, position,-sin(global_rotation.y))
	pass # Replace with function body.
