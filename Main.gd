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

# Audio resources
const SFX_JUMP = preload("res://assets/coin-collect-retro-8-bit-sound-effect-145251.mp3")
const MUSIC_MAIN = preload("res://assets/game-8-bit-399898.mp3")
const BG_TEX = preload("res://assets/background.png")

var sfx_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var bg_sprite: Sprite2D
var bg_color_sprite: Sprite2D
var _last_viewport_size := Vector2.ZERO

func _ready():
	# This node needs to process input even when paused to handle restarts.
	process_mode = Node.PROCESS_MODE_ALWAYS

	player.hit.connect(_on_player_hit)
	player.jumped.connect(_on_player_jumped)
	obstacle_spawner.timeout.connect(_on_obstacle_timer_timeout)
	
	# Create and populate the obstacle pool
	for i in OBSTACLE_POOL_SIZE:
		var obstacle = OBSTACLE_SCENE.instantiate()
		obstacle.returned_to_pool.connect(_on_obstacle_returned_to_pool)
		if obstacle.has_signal("passed"):
			obstacle.passed.connect(_on_obstacle_passed)
		if obstacle.has_signal("touched"):
			obstacle.touched.connect(_on_obstacle_touched)
		_obstacle_pool.append(obstacle)
	
	# Create audio players
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SfxPlayer"
	sfx_player.stream = SFX_JUMP
	add_child(sfx_player)

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.stream = MUSIC_MAIN
	add_child(music_player)

	# Create a 1x1 white texture to use for the solid background color
	var img := Image.new()
	img.create(1, 1, false, Image.FORMAT_RGBA8)
	img.set_pixel(0, 0, Color(1, 1, 1, 1))
	var color_tex := ImageTexture.create_from_image(img)

	bg_color_sprite = Sprite2D.new()
	bg_color_sprite.name = "BackgroundColor"
	bg_color_sprite.texture = color_tex
	bg_color_sprite.modulate = Color8(0x37, 0x8e, 0xb5)
	bg_color_sprite.z_index = -200
	add_child(bg_color_sprite)

	# Create background image sprite above the color background
	bg_sprite = Sprite2D.new()
	bg_sprite.name = "Background"
	bg_sprite.texture = BG_TEX
	bg_sprite.z_index = -100
	add_child(bg_sprite)

	# Initial sizing/position
	_update_background()
	start_game()

func _process(delta):
	# Keep background sized to the viewport if the window resizes
	var vs = get_viewport_rect().size
	if vs != _last_viewport_size:
		_update_background()

	# Update gameplay (score) only when active
	if not game_active:
		return

	# Update score based on distance
	score += int(ROAD_SPEED * delta / 10)
	score_label.text = "Score: " + str(score)


func _update_background():
	if not bg_sprite or not bg_sprite.texture:
		return
	var vs = get_viewport_rect().size
	_last_viewport_size = vs
	var tex_size = bg_sprite.texture.get_size()
	if tex_size.x == 0 or tex_size.y == 0:
		return
	# Scale to cover the viewport while preserving aspect ratio
	#var sx = vs.x / tex_size.x
	#var sy = vs.y / tex_size.y
	#var s = max(sx, sy)
	#bg_sprite.scale = Vector2(s, s)
	# Center the background image sprite
	bg_sprite.position = vs * 0.5
	bg_sprite.position.x = 0
	bg_sprite.scale = Vector2(2,2)

	# Resize and position the solid color sprite to cover the viewport
	#bg_color_sprite.scale = Vector2(vs.x * 4, vs.y)
	#bg_color_sprite.position = vs * 0.5


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

	# Restart music when a new game starts
	if music_player:
		music_player.stop()
		music_player.play()

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
	
	# Position and add the obstacle to the scene at the player's Y for consistent height
	#var spawn_pos = Vector2(1100, player.global_position.y)
	var spawn_pos = Vector2(1100, 550)
	obstacles_container.add_child(obstacle)
	obstacle.start(spawn_pos)

func _on_obstacle_returned_to_pool(obstacle):
	# The obstacle has already removed itself from the scene tree.
	# It is now available for reuse.
	pass

func _on_obstacle_passed(obstacle):
	# Increment score when the player successfully passes an obstacle while in the air.
	if not game_active:
		return
	score += 1
	score_label.text = "Score: " + str(score)

func _on_player_jumped():
	if sfx_player:
		sfx_player.play()

func _on_obstacle_touched(obstacle):
	if sfx_player:
		sfx_player.play()
