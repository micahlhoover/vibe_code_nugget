extends Node2D

const LAMPPOST_SPEED_MULTIPLIER = 0.5 # Corresponds to parallax scale(0.5, 0.5)
const WORLD_SPEED = 300.0
const LAMPPOST_SPEED = WORLD_SPEED * LAMPPOST_SPEED_MULTIPLIER

const SCREEN_WIDTH = 1024
const SPAWN_X_RIGHT = 1100
const DESPAWN_X_LEFT = -1200
const NUM_LAMPPOSTS = 4

@onready var lamppost_texture = preload("res://assets/lamppost.png")
var lampposts: Array[Sprite2D]

func _ready():
	# Pre-spawn a pool of lampposts
	for i in NUM_LAMPPOSTS:
		var lamp = Sprite2D.new()
		lamp.texture = lamppost_texture
		add_child(lamp)
		lampposts.append(lamp)
	reset_lampposts()

func reset_lampposts():
	# Scatter the lampposts at the start of the game
	for i in range(NUM_LAMPPOSTS):
		var x_pos = i * (SCREEN_WIDTH / (NUM_LAMPPOSTS - 1)) + randf_range(-100, 100)
		lampposts[i].position = Vector2(x_pos, 420)

func _process(delta):
	# Move each lamppost and reset it if it goes off-screen
	for lamp in lampposts:
		lamp.position.x -= LAMPPOST_SPEED * delta
		if lamp.position.x < DESPAWN_X_LEFT:
			# Reset its position to the right side, with a little variation
			lamp.position.x = SPAWN_X_RIGHT + randf_range(0, 200)
