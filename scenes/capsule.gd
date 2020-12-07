extends Node2D

enum capsules {
	CAPSULE_DRAGON,
	CAPSULE_STARLINER
}

var current_capsule: int = capsules.CAPSULE_DRAGON

var precision_mode: bool = false
var can_control: bool = false

var velocity: Vector2 = Vector2(0, 0)
var rot_velocity: float = 0
var thrust = [Vector3(5, 5, 0.05), Vector3(5, 5, 0.07)]

onready var dock_position = [$dragon/docking_center.position, $starliner/docking_center.position]

func _ready() -> void:
	set_physics_process(true)
	set_capsule(current_capsule)

func get_dock_position() -> Vector2:
	return dock_position[current_capsule]

func set_capsule(capsule: int) -> void:
	if capsule == capsules.CAPSULE_DRAGON:
		current_capsule = capsules.CAPSULE_DRAGON
		$dragon.show()
		$starliner.hide()
	else:
		current_capsule = capsules.CAPSULE_STARLINER
		$dragon.hide()
		$starliner.show()

func _physics_process(delta: float) -> void:
	if can_control:
		if precision_mode:
			if Input.is_action_just_pressed("thrust_up"):
				velocity -= Vector2(0, thrust[current_capsule].y).rotated(rotation)
			if Input.is_action_just_pressed("thrust_down"):
				velocity += Vector2(0, thrust[current_capsule].y).rotated(rotation)
			if Input.is_action_just_pressed("thrust_backwards"):
				velocity -= Vector2(thrust[current_capsule].x, 0).rotated(rotation)
			if Input.is_action_just_pressed("thrust_forwards"):
				velocity += Vector2(thrust[current_capsule].x, 0).rotated(rotation)
			if Input.is_action_just_pressed("thrust_ccw"):
				rot_velocity -= thrust[current_capsule].z
			if Input.is_action_just_pressed("thrust_cw"):
				rot_velocity += thrust[current_capsule].z
		else:
			if Input.is_action_pressed("thrust_up"):
				velocity -= Vector2(0, thrust[current_capsule].y).rotated(rotation)
			if Input.is_action_pressed("thrust_down"):
				velocity += Vector2(0, thrust[current_capsule].y).rotated(rotation)
			if Input.is_action_pressed("thrust_backwards"):
				velocity -= Vector2(thrust[current_capsule].x, 0).rotated(rotation)
			if Input.is_action_pressed("thrust_forwards"):
				velocity += Vector2(thrust[current_capsule].x, 0).rotated(rotation)
			if Input.is_action_pressed("thrust_ccw"):
				rot_velocity -= thrust[current_capsule].z
			if Input.is_action_pressed("thrust_cw"):
				rot_velocity += thrust[current_capsule].z

		if Input.is_action_just_pressed("ui_select"):
			precision_mode = !precision_mode

		rotation += rot_velocity * delta
		position += velocity * delta
