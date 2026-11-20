@tool
extends MeshInstance3D

var max_points = 30
var position_history =  []

func _update_max_points(val):
	max_points = val
	material_overlay.set_shader_parameter("MAX_POINTS", max_points)
	_adjust_history_size()
func _adjust_history_size():
	if position_history.size() != max_points:
		position_history.resize(max_points)
		position_history.fill(global_position)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_adjust_history_size()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position_history.insert(0, global_position)
	position_history.pop_back()
	
	if material_override:
		material_override.set_shader_parameter("positions", position_history)
	pass
