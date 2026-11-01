extends Node3D
signal plane_entered

@onready var p1_health: Label3D = $p2_health
@onready var p2_health: Label3D = $p1_health
@onready var cam: Camera3D = $Camera3D
@export var p1: CharacterBody3D
@export var p2: CharacterBody3D

const SPEED = 1
# Called when. the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#position.y = move_toward(position.y, 100, SPEED * delta)
	p1_health.text = "%.2f %%" % p1.total_damage
	p2_health.text = "%.2f %%" % p2.total_damage
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:

	plane_entered.emit(body, cam.position)


	pass # Replace with function body.
