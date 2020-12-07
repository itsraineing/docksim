extends Node2D

var window_size: Vector2 = Vector2(0, 0)
var bg_size: Vector2 = Vector2(1920, 1440)
var window_edge: Vector2 = Vector2(0, 0)
var sim_edge_margin: Vector2 = Vector2(200, 265)

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "update_bg")
	update_bg()
	pass

func update_bg() -> void:
	window_size = OS.window_size

	var center: Vector2 = $Camera2D.position
	$bg.position = center

	var bg_scale: float = 0
	if (bg_size.x / window_size.x) < (bg_size.y / window_size.y):
		bg_scale = window_size.x / bg_size.x
	else:
		bg_scale = window_size.y / bg_size.y

	$bg.scale = Vector2(bg_scale, bg_scale)

	window_edge.x = (window_size.x / 2) + center.x
	window_edge.y = center.y - (window_size.y / 2)

	$sim.position.x = window_edge.x - sim_edge_margin.x
	$sim.position.y = window_edge.y + sim_edge_margin.y
