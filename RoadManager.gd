extends Node2D

const ROAD_SPEED = 300.0
const ROAD_WIDTH = 1024
# How far apart the leading edges of road tiles should be (smaller => closer together)
# Use a spacing <= ROAD_WIDTH so tiles touch/overlap (remove gaps).
const ROAD_SPACING = 512

@onready var sprite1: Sprite2D = $RoadSprite1
@onready var sprite2: Sprite2D = $RoadSprite2

var roads: Array = []
const INITIAL_ROAD_COUNT = 5

func _ready():
	# Position the sprites side-by-side
	# Build an initial array of road tiles and duplicate additional tiles so the
	# scene has many road pieces available. Position them to cover the viewport
	# immediately.
	roads.clear()
	roads.append(sprite1)
	roads.append(sprite2)

	# Duplicate sprite2 (or sprite1) to reach INITIAL_ROAD_COUNT
	for i in range(2, INITIAL_ROAD_COUNT):
		var new_sprite = sprite1.duplicate()
		new_sprite.name = "RoadSprite%d" % (i + 1)
		add_child(new_sprite)
		roads.append(new_sprite)

	# Position the road tiles consecutively to cover the viewport
	var x = 0
	for r in roads:
		r.position.x = x
		x += ROAD_SPACING

func _process(delta: float) -> void:
	# Move all road tiles to the left
	for r in roads:
		r.position.x -= ROAD_SPEED * delta

	# Recycle any road tile that moved fully off the left edge by placing it
	# to the right of the current rightmost tile. This keeps a continuous
	# stream of road pieces without gaps.
	for r in roads:
		if r.position.x < -ROAD_WIDTH:
			var rightmost = -INF
			for rr in roads:
				if rr == r:
					continue
				rightmost = max(rightmost, rr.position.x)

			if rightmost == -INF:
				rightmost = get_viewport_rect().size.x

			r.position.x = rightmost + ROAD_SPACING
