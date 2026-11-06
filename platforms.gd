extends Node3D

signal ledge_grab
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for child in get_children():
		child.ledge_grab.connect(_on_grab)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_grab(body, gposition,dir):
	print("Grab Attempt: %s" % body.name)
	ledge_grab.emit(body, gposition,dir)
