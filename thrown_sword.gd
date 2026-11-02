extends RigidBody3D


@export var thrown_sword_scene: PackedScene
@onready var held_sword = $Skeleton3D/BoneAttachment3D/Sword2 # Adjust path as needed

func execute_throw():
	held_sword.hide() # Make the hand weapon invisible
	
	# Spawn the flying weapon
	var projectile = thrown_sword_scene.instantiate()
	get_tree().root.add_child(projectile) # Add it to the world, not the player
	
	# Snap the flying weapon to the exact position and angle of the hand weapon
	projectile.global_transform = held_sword.global_transform
	
	# Example: Push it forward (if using RigidBody3D)
	# projectile.linear_velocity = -projectile.global_transform.basis.z * 15.0
