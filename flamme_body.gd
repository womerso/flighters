extends Node3D

@export var anim_player: AnimationPlayer
@export var idle_player: AnimationPlayer
@export var anim_tree: AnimationTree

var is_jump = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_tree.active = true

func update_animation_params(dir:Vector2):
	if is_jump:
		return
	anim_tree.set("parameters/conditions/is_moving", dir != Vector2.ZERO)
	anim_tree.set("parameters/conditions/idle", dir == Vector2.ZERO)
	
	#anim_tree.set("parameters/conditions/attack", false)




func _on_flamme_attack() -> void:
	print("hello")
	anim_tree.set("parameters/conditions/attack", true)
	pass # Replace with function body.


func _on_flamme_animate(dir:Vector2) -> void:
	update_animation_params(dir)
	
	pass # Replace with function body.


func _on_flamme_jump() -> void:
	print("jump")
	is_jump = true
	anim_tree.set("parameters/conditions/jump", is_jump)
	#anim_tree.set("parameters/conditions/idle", false)
	pass # Replace with function body.


func _on_flamme_end_jump() -> void:
	print("end_jump")
	is_jump = false
	anim_tree.set("parameters/conditions/jump", is_jump)
	pass # Replace with function body.


func _on_flamme_move_right() -> void:
	pass # Replace with function body.
