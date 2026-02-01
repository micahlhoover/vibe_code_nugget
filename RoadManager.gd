extends Node2D

const ROAD_SPEED = 300.0
const ROAD_WIDTH = 1024

@onready var sprite1: Sprite2D = $RoadSprite1
@onready var sprite2: Sprite2D = $RoadSprite2

func _ready():
	# Position the sprites side-by-side
	sprite1.position.x = 0
	sprite2.position.x = ROAD_WIDTH

func _process(delta: float) -> void:
	# Move both sprites to the left
	sprite1.position.x -= ROAD_SPEED * delta
	sprite2.position.x -= ROAD_SPEED * delta
	
	# If a sprite has moved completely off-screen to the left,
	# "leapfrog" it to the right side of the other sprite.
	if sprite1.position.x < -ROAD_WIDTH:
		sprite1.position.x += ROAD_WIDTH * 2
	
	if sprite2.position.x < -ROAD_WIDTH:
		sprite2.position.x += ROAD_WIDTH * 2
