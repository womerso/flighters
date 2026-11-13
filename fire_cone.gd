@tool
extends Node3D

@onready var mat: MeshInstance3D = $Cylinder
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pic = load("res://Textures/T_AuraC12.jpg")
	var  shader = mat.get_active_material(0)
	shader.set_shader_parameter("fire_tex", pic)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
