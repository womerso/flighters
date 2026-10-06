extends StaticBody3D

signal ledge_grab
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func _on_ledge_grab_left_body_exited(body: Node3D) -> void:
	ledge_grab.emit(body.name)
	pass # Replace with function body.


func _on_ledge_grab_right_body_exited(body: Node3D) -> void:
	ledge_grab.emit(body.name)
	pass # Replace with function body.
