extends CharacterBody2D

signal timer_updated(time_text: String)
signal timer_finished(time_text: String)

const SPEED := 2000
const GOAL_REACH_DISTANCE := 12.0

var timer_started := false
var time_elapsed := 0.0
var finished := false

@onready var animatedSprite = $animatedsprite

func _physics_process(delta):
	var direction := Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
		animatedSprite.frame = 2
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
		animatedSprite.frame = 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
		animatedSprite.frame = 0
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
		animatedSprite.frame = 3

	if direction != Vector2.ZERO and not timer_started:
		timer_started = true
		time_elapsed = 0.0
		print("Timer started!")

	if timer_started and not finished:
		time_elapsed += delta
		emit_signal("timer_updated", format_time(time_elapsed))

		var game_node = get_parent()
		if game_node:
			var goal_pos = game_node.goal_position
			if position.distance_to(goal_pos) <= GOAL_REACH_DISTANCE:
				finished = true
				emit_signal("timer_finished", format_time(time_elapsed))
				print("Finished by position! Time: ", format_time(time_elapsed))
	velocity = direction.normalized() * SPEED
	move_and_slide()

func format_time(t: float) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	var milliseconds = int((t - int(t)) * 1000)
	return "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
