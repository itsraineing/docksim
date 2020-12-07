extends Node2D

enum capsules {
	CAPSULE_DRAGON,
	CAPSULE_STARLINER
}

var current_capsule: int = capsules.CAPSULE_DRAGON

var velocity: Vector2 = Vector2(0, 0)
var rot_velocity: float = 0
var thrust = [Vector3(15, 10, 0.5), Vector3(10, 15, 0.7)]

func _ready() -> void:
	set_physics_process(true)
	$dragon.show()
	$starliner.hide()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("thrust_up"):
		velocity -= Vector2(0, thrust[current_capsule].y).rotated(rotation)
	if Input.is_action_pressed("thrust_down"):
		velocity += Vector2(0, thrust[current_capsule].y).rotated(rotation)
	if Input.is_action_pressed("thrust_backwards"):
		velocity -= Vector2(thrust[current_capsule].x, 0).rotated(rotation)
	if Input.is_action_pressed("thrust_forwards"):
		velocity += Vector2(thrust[current_capsule].x, 0).rotated(rotation)

	position += velocity * delta

	if Input.is_action_pressed("thrust_ccw"):
		rot_velocity -= thrust[current_capsule].z
	if Input.is_action_pressed("thrust_cw"):
		rot_velocity += thrust[current_capsule].z

	rotation += rot_velocity * delta

	if Input.is_action_just_pressed("ui_select"):
		if current_capsule == capsules.CAPSULE_DRAGON:
			current_capsule = capsules.CAPSULE_STARLINER
			$dragon.hide()
			$starliner.show()
		else:
			current_capsule = capsules.CAPSULE_DRAGON
			$dragon.show()
			$starliner.hide()
