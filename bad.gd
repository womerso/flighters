extends CharacterBody3D

signal die

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var lives = 3
var hurt = false
var dead = false
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if not dead and lives == 0:
		print("oh no i died")
		$BodyCollision.set("active", false)
		die.emit()
		dead = true

	move_and_slide()


func _on_flamme_connect(nme) -> void:
	if nme == name:
		lives -=1
	pass # Replace with function body.
