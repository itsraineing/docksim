extends Node2D

var window_size: Vector2 = Vector2(0, 0)
var bg_size: Vector2 = Vector2(1920, 1440)
var window_edge: Vector2 = Vector2(0, 0)
var sim_edge_margin: Vector2 = Vector2(200, 265)
var status_edge_margin: Vector2 = Vector2(20, 20)

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "update_bg")
	update_bg()

	set_physics_process(true)
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

	$status_display.position.x = -window_edge.x + status_edge_margin.x

	$status_display/telemetry_label.position.y = window_edge.y + status_edge_margin.y
	$status_display/precision_label.position.y = -window_edge.y - status_edge_margin.y

func _physics_process(delta: float) -> void:
	var capsule_dock: Vector2 = $sim/capsule.get_dock_position() + $sim/capsule.position
	var capsule_rot = $sim/capsule.rotation
	var ida_dock: Vector2 = $sim/ida.position

	var rot_vector: Vector2 = Vector2(cos(capsule_rot), sin(capsule_rot))
	var rot_distance: float = rot_vector.distance_to(Vector2(1, 0)) * 180
	if sin(capsule_rot) < 0:
		rot_distance = -rot_distance

	var distance: Vector2 = capsule_dock - ida_dock
	var label_string = "distance to port: {h}\nx: {x}\ny: {y}\nrotation: {r}"

	var distance_str = str(distance.length()).pad_decimals(3)
	var x_str = str(distance.x).pad_decimals(3)
	var y_str = str(distance.y).pad_decimals(3)
	var rot_str = str(rot_distance).pad_decimals(3)
	label_string = label_string.format({"h" : distance_str, "x" : x_str, "y" : y_str, "r" : rot_str})

	$status_display/telemetry_label/Label.text = label_string

	if $sim/capsule.precision_mode:
		$status_display/precision_label/Label.text = "Precision mode"
	else:
		$status_display/precision_label/Label.text = "Coarse mode"
