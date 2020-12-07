extends Node2D

enum capsules {
	CAPSULE_DRAGON,
	CAPSULE_STARLINER
}

var current_capsule: int = capsules.CAPSULE_DRAGON

func _ready() -> void:
	set_physics_process(true)
	$dragon.show()
	$starliner.hide()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_up"):
		position.y -= 10
	if Input.is_action_pressed("ui_down"):
		position.y += 10
	if Input.is_action_pressed("ui_left"):
		position.x -= 10
	if Input.is_action_pressed("ui_right"):
		position.x += 10

	if Input.is_action_just_pressed("ui_select"):
		if current_capsule == capsules.CAPSULE_DRAGON:
			current_capsule = capsules.CAPSULE_STARLINER
			$dragon.hide()
			$starliner.show()
		else:
			current_capsule = capsules.CAPSULE_DRAGON
			$dragon.show()
			$starliner.hide()
