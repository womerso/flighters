extends Node3D

@export var anim_player: AnimationPlayer
@export var anim_tree: AnimationTree

var playback
var is_attacking = false
signal attack_finish
signal connect
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_tree.active = true
	playback = anim_tree.get("parameters/playback")
	pass # Replace with function body.

func get_anim_state():
	return anim_tree.get("parameters/playback").get_current_node()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var cn = get_anim_state()
	#print(is_attacking)
	if cn == "Backflip":
		rotation_degrees.y = 90
	pass
func update_animation_params(dir:Vector2):
	if not is_attacking:
		if dir.y > .7:
			if abs(dir.x) < 0.1:
				anim_tree.set("parameters/conditions/is_crouched", true)
				anim_tree.set("parameters/conditions/is_idle", false)
				anim_tree.set("parameters/conditions/crouch_move", false)
			else:
				anim_tree.set("parameters/conditions/is_crouched", false)
				anim_tree.set("parameters/conditions/crouch_move", true)
				anim_tree.set("parameters/conditions/is_moving", false)
		else :
			anim_tree.set("parameters/conditions/is_idle", dir == Vector2.ZERO)
			anim_tree.set("parameters/conditions/is_moving", dir != Vector2.ZERO)
			anim_tree.set("parameters/conditions/crouch_move", false)
			anim_tree.set("parameters/conditions/is_crouched", false)
func _on_flamme_animate(dir:Vector2) -> void:
	update_animation_params(dir)
	
	
func _on_flamme_down_n() -> void:
	
	pass # Replace with function body.


func _on_flamme_attack(count: int) -> void:
	print("parameters/conditions/attack_%d" % count)
	anim_tree.set("parameters/conditions/attack_%d" % count, true)
	if count > 1:
		anim_tree.set("parameters/conditions/attack_%d" % (count-1), false)
	anim_tree.set("parameters/conditions/is_idle", false)
	anim_tree.set("parameters/conditions/is_moving", false)
	is_attacking = true
	pass # Replace with function body.



func _on_flamme_jump() -> void:
	if anim_tree.get("parameters/conditions/is_jump"):
		
		anim_tree.set("parameters/conditions/double_jump", true)
		anim_tree.set("parameters/BackFlip/TimeSeek/seek_request", 0.6)
		return
	anim_tree.set("parameters/conditions/is_jump", true)
	anim_tree.set("parameters/conditions/landed", false)
	pass # Replace with function body.


func _on_flamme_end_jump() -> void:
	anim_tree.set("parameters/conditions/is_jump", false)

	anim_tree.set("parameters/conditions/landed", true)
	anim_tree.set("parameters/conditions/double_jump", false)
	pass # Replace with function body.


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if "Sword" in anim_name:
		attack_finish.emit()
	pass # Replace with function body.


func _on_flamme_end_attack() -> void:
	is_attacking = false
	anim_tree.set("parameters/conditions/attack_1", false)
	anim_tree.set("parameters/conditions/attack_2", false)
	anim_tree.set("parameters/conditions/attack_3", false)
	
	pass # Replace with function body.


func _on_sword_box_body_entered(body: Node3D) -> void:
	return
	print("HELLLOOOO")
	connect.emit(body.name)


func _on_sword_box_body_exited(body: Node3D) -> void:
	connect.emit(body.name)


func _on_flamme_die() -> void:
	playback.start("Death_A")
	pass # Replace with function body.


func _on_flamme_up_b() -> void:
	anim_tree.set("parameters/conditions/up_b", true)
	anim_tree.set("parameters/conditions/double_jump", false)
	pass # Replace with function body.


func _on_flamme_end_up_b() -> void:
	anim_tree.set("parameters/conditions/up_b", false)
	pass # Replace with function body.


func _on_flamme_crouched() -> void:
	pass # Replace with function body.
