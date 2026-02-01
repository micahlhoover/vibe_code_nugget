extends Node2D

const ROAD_SPEED = 300.0

@onready var player = $Nugget
@onready var game_over_ui = $GameOverUI
@onready var score_label = $UI/ScoreLabel
@onready var obstacle_spawner = $ObstacleSpawner
@onready var obstacles_container = $Obstacles
@onready var lamppost_manager = $LamppostManager

const OBSTACLE_SCENE = preload("res://obstacle.tscn")
var _obstacle_pool = []
const OBSTACLE_POOL_SIZE = 8

var score = 0
var game_active = false

func _ready():
	# This node needs to process input even when paused to handle restarts.
	process_mode = Node.PROCESS_MODE_ALWAYS

	player.hit.connect(_on_player_hit)
	obstacle_spawner.timeout.connect(_on_obstacle_timer_timeout)
	
	# Create and populate the obstacle pool
	for i in OBSTACLE_POOL_SIZE:
		var obstacle = OBSTACLE_SCENE.instantiate()
		obstacle.returned_to_pool.connect(_on_obstacle_returned_to_pool)
		_obstacle_pool.append(obstacle)
	
	start_game()

func _process(delta):
	if not game_active:
		return
		
	# Update score based on distance
	score += int(ROAD_SPEED * delta / 10)
	score_label.text = "Score: " + str(score)

func _input(event):
	# Listen for restart action only when the game is over and paused.
	if get_tree().paused and (event is InputEventMouseButton or event.is_action_pressed("ui_accept")):
		restart_game()

func start_game():
	score = 0
	score_label.text = "Score: 0"
	get_tree().paused = false
	game_active = true 
	
	player.reset_player()
	lamppost_manager.reset_lampposts()
	game_over_ui.hide()
	obstacle_spawner.start()

func restart_game():
	# Clear any obstacles currently on screen
	for obstacle in obstacles_container.get_children():
		obstacle.get_parent().remove_child(obstacle)
	
	start_game()

func _on_player_hit():
	game_active = false
	obstacle_spawner.stop()
	game_over_ui.show()
	# The tree is paused to stop all physics and animations.
	get_tree().paused = true


func _on_obstacle_timer_timeout():
	var obstacle = null
	for o in _obstacle_pool:
		if o.get_parent() == null:
			obstacle = o
			break
	
	if not obstacle:
		print_debug("Obstacle pool exhausted. Consider increasing pool size.")
		return
	
	# Position and add the obstacle to the scene
	var spawn_pos = Vector2(1100, randf_range(480, 690))
	obstacles_container.add_child(obstacle)
	obstacle.start(spawn_pos)

func _on_obstacle_returned_to_pool(obstacle):
	# The obstacle has already removed itself from the scene tree.
	# It is now available for reuse.
	pass
