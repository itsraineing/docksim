extends Node2D

enum lose_reason {
	LOSE_TOO_FAST,
	LOSE_TOO_FAR
}

var game_running: bool = false
var won: bool = false

var window_size: Vector2 = Vector2(0, 0)
var bg_size: Vector2 = Vector2(1920, 1440)
var window_edge: Vector2 = Vector2(0, 0)
var sim_edge_margin: Vector2 = Vector2(176, 188)
var status_edge_margin: Vector2 = Vector2(20, 20)

var label_string = "distance to port: {h}m\nx: {x}m\ny: {y}m\nrotation: {r} deg\nvelocity: {v}m/s"
var lose_message = ["Whoops!\nYou were going too fast!\nDocking must be at <1m/s",
"Whoops!\nYou missed the station!\nTry to be more gentle!"]

var win_timer: float = 0
var win_anim_length: float = 5

var won_position: Vector2
var won_rotation: float

var dock_position = [Vector2(-180, 14), Vector2(-158, 1)]

func _ready() -> void:
	randomize()
	get_tree().get_root().connect("size_changed", self, "update_bg")
	update_bg()
	reset_game()

func lose_game(reason: int) -> void:
	game_running = false
	$sim/capsule.can_control = false
	$menu/lose_menu/Label2.text = lose_message[reason]
	$menu/lose_menu.show()
	set_physics_process(false)

func win_game() -> void:
	game_running = false
	won = true
	$sim/capsule.can_control = false
	$menu/win_menu.show()

func reset_game() -> void:
	$sim/capsule.velocity = Vector2(0, 0)
	$sim/capsule.rot_velocity = 0
	$sim/capsule.hide()
	$status_display.hide()
	$menu/initial_menu.show()
	$menu/win_menu.hide()
	$menu/lose_menu.hide()
	won = false
	win_timer = 0
	won_position = Vector2(0, 0)
	won_rotation = 0

func start_game(capsule: int) -> void:
	game_running = true
	$menu/initial_menu.hide()
	$sim/capsule.set_capsule(capsule)
	$sim/capsule.position = Vector2(rand_range(-1045, -426), rand_range(-20, 555))
	$sim/capsule.rotation = rand_range(130, -60)
	$sim/capsule.can_control = true
	$sim/capsule.show()
	$status_display.show()
	set_physics_process(true)

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

	distance /= 30

	var distance_str = str(distance.length()).pad_decimals(3)
	var x_str = str(distance.x).pad_decimals(3)
	var y_str = str(distance.y).pad_decimals(3)
	var rot_str = str(rot_distance).pad_decimals(3)
	var vel_str = str($sim/capsule.velocity.length() / 30).pad_decimals(3)
	$status_display/telemetry_label/Label.text = label_string.format({"h" : distance_str, "x" : x_str, "y" : y_str, "r" : rot_str, "v" : vel_str})

	if $sim/capsule.precision_mode:
		$status_display/precision_label/Label.text = "Precision mode"
	else:
		$status_display/precision_label/Label.text = "Coarse mode"

	print($sim/capsule.position)

	# game over conditions
	if game_running:
		if distance.x < -42 or distance.x > 15 or distance.y > 25 or distance.y < -15:
			lose_game(lose_reason.LOSE_TOO_FAR)
		elif distance.x >= -1.5 and distance.x <= 0 and abs(distance.y) <= 2 and abs(rot_distance) <= 15:
			if ($sim/capsule.velocity.length() / 30) < 1 and $sim/capsule.rot_velocity < 1:
				win_game()
				won_position = $sim/capsule.position
				won_rotation = $sim/capsule.rotation
			else:
				lose_game(lose_reason.LOSE_TOO_FAST)

	if won:
		win_timer += delta
		if win_timer > win_anim_length:
			won = false

		var capsule = $sim/capsule.current_capsule
		$sim/capsule.position = Vector2(lerp(won_position.x, dock_position[capsule].x, win_timer / 5),
				lerp(won_position.y, dock_position[capsule].y, win_timer / 5))
		$sim/capsule.rotation = lerp_angle(won_rotation, 0, win_timer / 5)

func _on_dragon_button_pressed() -> void:
	start_game(0)

func _on_starliner_button_pressed() -> void:
	start_game(1)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_replay_button_pressed() -> void:
	reset_game()
