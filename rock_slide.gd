extends Area3D
@onready var rocks: GPUParticles3D = $rocks
const SPEED = 10
var dir = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var r_p: ParticleProcessMaterial = rocks.process_material

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	position.x += SPEED * delta * dir
	pass
