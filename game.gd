extends Node2D

const WALL_SCENE = preload("res://mazewall.tscn")
const GOAL_SCENE = preload("res://end.tscn")
const PLAYER_SCENE = preload("res://player.tscn")

@onready var timer_label = $timer
@onready var date_label = $date
@onready var todaysbest_label = $todaysbest

const WIDTH := 31
const HEIGHT := 17
const TILE_SIZE := 30
const TOP_LEFT_POS := Vector2(-404, -240)

var grid = []
var stack = []

var player: Node2D
var goal_position := Vector2.ZERO

func _ready():
	var date = get_date()
	#randomize()
	seed(int("%04d%02d%02d" % [date.year, date.month, date.day]))
	#seed(int("%04d%02d%02d" % [2025, 1, 1]))
	generate_maze()
	place_player()
	place_maze()
	
	player.timer_updated.connect(_on_timer_updated)
	player.timer_finished.connect(_on_timer_finished)

func generate_maze():
	grid.resize(HEIGHT)
	for y in range(HEIGHT):
		grid[y] = []
		for x in range(WIDTH):
			grid[y].append(true)

	var start_x = 1
	var start_y = 1

	grid[start_y][start_x] = false
	grid[start_y][start_x - 1] = false  # entrance

	stack.append(Vector2i(start_x, start_y))

	while stack.size() > 0:
		var current = stack[-1]
		var neighbors = get_unvisited_neighbors(current.x, current.y)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			var wall_x = (current.x + next.x) / 2
			var wall_y = (current.y + next.y) / 2
			grid[wall_y][wall_x] = false
			grid[next.y][next.x] = false
			stack.append(next)
		else:
			stack.pop_back()

func get_unvisited_neighbors(x, y):
	var dirs = [Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)]
	var result = []
	for dir in dirs:
		var nx = x + dir.x
		var ny = y + dir.y
		if nx > 0 and ny > 0 and nx < WIDTH - 1 and ny < HEIGHT - 1 and grid[ny][nx]:
			result.append(Vector2i(nx, ny))
	return result

func place_player():
	var start_x = 1
	var start_y = 1
	player = PLAYER_SCENE.instantiate()
	player.position = TOP_LEFT_POS + Vector2((start_x - 1) * TILE_SIZE, start_y * TILE_SIZE)
	add_child(player)
	player.add_to_group("player")

func place_maze():
	for y in range(HEIGHT):
		for x in range(WIDTH):
			var pos = TOP_LEFT_POS + Vector2(x * TILE_SIZE, y * TILE_SIZE)
			if grid[y][x]:
				var wall = WALL_SCENE.instantiate()
				wall.position = pos
				add_child(wall)

	# Place goal at bottom-right open tile
	for y in range(HEIGHT - 1, -1, -1):
		for x in range(WIDTH - 1, -1, -1):
			if !grid[y][x]:
				var goal = GOAL_SCENE.instantiate()
				goal.position = TOP_LEFT_POS + Vector2(x * TILE_SIZE, y * TILE_SIZE)
				add_child(goal)
				goal_position = goal.position
				return
				
func _on_timer_updated(time_text: String):
	timer_label.text = time_text

func _on_timer_finished(time_text: String):
	timer_label.text = time_text
	print("Finished! Time: ", time_text)
	#print("comparing best vs newtime: " + str(int(todaysbest_label.text)) +" "+ str(int(time_text)))
	if int(todaysbest_label.text) > int(time_text) or todaysbest_label.text == "Today's Best:":
		todaysbest_label.text = "Today's Best: " + time_text

func get_date():
	var date = Time.get_date_dict_from_system()
	var formatted := "%02d/%02d/%04d" % [date.day, date.month, date.year]
	date_label.text = formatted
	return date

func restartGame() -> void:
	player.timer_started = false
	player.time_elapsed = 0.0
	player.finished = false
	player.position = TOP_LEFT_POS + Vector2((1 - 1) * TILE_SIZE, 1 * TILE_SIZE)

	timer_label.text = "00:00:000"
