extends Node

var paddles: Array
var paddle_default: Dictionary = {
	"node": null, 
	"hrz": false, 
	"plr": 0, 
	"spd": 100, 
	"spdm": 1, 
	"vel": Vector2(0.0, 0.0), 
	"dir": Vector2(0.0, 0.0), 
	"pos_mod": 0.0
}
var balls: Array
var ball_default: Dictionary = {
	"node": null, 
	"hrz": false, 
	"pnd": null, 
	"spd": 50, 
	"spdm": 1, 
	"vel": Vector2(0.0, 0.0), 
	"dir": Vector2(0.0, 0.0), 
	"pos": Vector2(0.0, 0.0), 
	"temp": false
}
var game_on = false
var gamescreen = [Vector2(0.0, 0.0), Vector2(320, 180)]
var score = [0, 0]

var collision_sounds = ["res://assets/collision1.wav", "res://assets/collision2.wav", "res://assets/collision.wav"]
var goal_sound = "res://assets/goal2.wav"
@onready var wall_collision: AudioStreamPlayer = $wall_collision
@onready var paddle_collision: AudioStreamPlayer = $paddle_collision
@onready var goal: AudioStreamPlayer = $goal
@onready var selection: AudioStreamPlayer = $selection


var P1_CPU = false:
	set(value):
		if value == true:
			$interface / cpu1.text = "< CPU >"
		else:
			$interface / cpu1.text = "< HUM >"
		P1_CPU = value
var P2_CPU = false:
	set(value):
		if value == true:
			$interface / cpu2.text = "< CPU >"
		else:
			$interface / cpu2.text = "< HUM >"
		P2_CPU = value



func _ready() -> void :
	detect_paddles()
	detect_balls()



func _process(delta: float) -> void :
	if game_on == true:
		for paddle in paddles:
			get_input(paddle, delta)
		for ball in balls:
			get_movements(ball, delta)



func _input(event: InputEvent) -> void :
	if game_on == false:
		if event.is_action_pressed("Start"):
			match_start()
		if event.is_action_pressed("P1_left") or event.is_action_pressed("P1_right"):
			P1_CPU = !P1_CPU
			selection.play()
		if event.is_action_pressed("P2_left") or event.is_action_pressed("P2_right"):
			P2_CPU = !P2_CPU
			selection.play()


func get_input(paddle, delta):
	if paddle["plr"] == 1:
		if !P1_CPU:
			paddle["dir"] = Input.get_vector("P1_left", "P1_right", "P1_up", "P1_down")
		else:
			get_cpu_action(paddle, delta)
	elif paddle["plr"] == 2:
		if !P2_CPU:
			paddle["dir"] = Input.get_vector("P2_left", "P2_right", "P2_up", "P2_down")
		else:
			get_cpu_action(paddle, delta)
	paddle["vel"] = paddle["dir"] * paddle["spd"] * paddle["spdm"] * Vector2(float(paddle["hrz"]), float( !paddle["hrz"]))
	var next_pos = paddle["node"].position + paddle["vel"] * delta
	var global_poly: PackedVector2Array
	for point in paddle["node"].get_child(0)["polygon"]:
		global_poly.append(point + next_pos)
	var move = true
	if global_poly[0].y <= gamescreen[0].y:
		move = false
		paddle["node"].position.y = gamescreen[0].y
	if global_poly[3].y >= gamescreen[1].y:
		move = false
		paddle["node"].position.y = gamescreen[1].y - (global_poly[3].y - global_poly[0].y)
	if move == true:
		paddle["node"].position += paddle["vel"] * delta


func get_movements(ball, delta):
	var next_pos = ball["node"].position + (ball["dir"] * ball["spd"] * ball["spdm"]) * delta
	for paddle in get_tree().get_nodes_in_group("paddle"):
		var global_poly: PackedVector2Array
		for point in paddle.get_child(0)["polygon"]:
			global_poly.append(point + paddle.position)
		var intersection = Geometry2D.intersect_polyline_with_polygon(PackedVector2Array([ball["node"].position, next_pos]), global_poly)
		if !intersection.is_empty():
			ball["spdm"] += 0.05
			var coll_point = intersection[0]
			var ball_y = ((coll_point[0].y - global_poly[0].y) / (global_poly[3].y - global_poly[0].y)) * 2 - 1
			ball["dir"] = Vector2( - ball["dir"].x, ball_y).normalized()
			ball["pnd"] = paddle
			paddle_collision.pitch_scale = pow(2.0, ((ball_y - 0.5) ** 2) / 4)
			paddle_collision.play()
	if next_pos.y <= gamescreen[0].y or next_pos.y >= gamescreen[1].y:
		ball["dir"] = Vector2(ball["dir"].x, - ball["dir"].y)
		wall_collision.play()
	ball["vel"] = ball["dir"] * ball["spd"] * ball["spdm"]
	ball["node"].position += ball["vel"] * delta
	if ball["node"].position.x <= gamescreen[0].x or ball["node"].position.x >= gamescreen[1].x:
		game_on = false
		if ball["node"].position.x <= gamescreen[0].x:
			score[0] += 1
		if ball["node"].position.x >= gamescreen[0].x:
			score[1] += 1
		$interface / score1.text = str(score[0])
		$interface / score1.visible = true
		$interface / score2.text = str(score[1])
		$interface / score2.visible = true
		$interface / text.text = "Pressione qualquer botão para continuar."
		$interface / text.visible = true
		$interface / commands1.visible = true
		$interface / commands2.visible = true
		$interface / cpu1.visible = true
		$interface / cpu2.visible = true
		ball["spdm"] = 1
		ball["node"].position = ball["pos"]
		goal.play()


func detect_paddles():
	paddles.clear()
	for paddle in get_tree().get_nodes_in_group("paddle"):
		var instance_paddle = paddle_default.duplicate()
		instance_paddle["node"] = paddle
		instance_paddle["hrz"] = paddle["metadata/horizontal_orientation"]
		instance_paddle["spd"] = paddle["metadata/default_speed"]
		instance_paddle["plr"] = paddle["metadata/player"]
		paddles.append(instance_paddle)


func detect_balls():
	balls.clear()
	for ball in get_tree().get_nodes_in_group("ball"):
		var instance_ball = ball_default.duplicate()
		instance_ball["node"] = ball
		instance_ball["hrz"] = ball["metadata/horizontal_orientation"]
		instance_ball["spd"] = ball["metadata/default_speed"]
		instance_ball["pos"] = ball.position
		balls.append(instance_ball)


func match_start():
	for ball in balls:
		var x = (randi() % 2) * 2 - 1
		var y = randf_range(-1, 1)
		ball["dir"] = Vector2(x, y).normalized()
		if x >= 0:
			var paddle = paddles[0]
			ball["pnd"] = paddle["node"]
		elif x < 0:
			var paddle = paddles[1]
			ball["pnd"] = paddle["node"]
	game_on = true
	$interface / text.visible = false
	$interface / score1.visible = false
	$interface / score2.visible = false
	$interface / commands1.visible = false
	$interface / commands2.visible = false
	$interface / cpu1.visible = false
	$interface / cpu2.visible = false
	for paddle in paddles:
		paddle["pos_mod"] = 0


func get_cpu_action(paddle, delta):
	var ball = balls[0]
	if ball["pnd"] != paddle["node"]:

		var global_poly: PackedVector2Array
		for point in paddle["node"].get_child(0)["polygon"]:
			global_poly.append(point + paddle["node"].position)
		var destiny = (ball["node"].position.y - (global_poly[3].y - global_poly[0].y) * (0.5 + paddle["pos_mod"])) - paddle["node"].position.y
		if abs(destiny) > 50.0:
			paddle["dir"].y = destiny / abs(destiny)
		paddle["dir"].y = lerp(paddle["dir"].y, destiny / abs(destiny), delta * 8)
	else:
		paddle["pos_mod"] = randf_range(-0.4, 0.4) * ball["spdm"]
		paddle["dir"] = Vector2(0.0, 0.0)
