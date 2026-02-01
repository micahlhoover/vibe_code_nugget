extends Camera2D

# This script makes the camera follow the player's Y position within set limits.

@onready var player: Node2D = get_parent().get_node("Nugget")

const Y_OFFSET = -150
const LIMIT_TOP = 260
const LIMIT_BOTTOM = 350

func _process(delta):
	if player:
		var target_y = player.global_position.y + Y_OFFSET
		global_position.y = clamp(target_y, LIMIT_TOP, LIMIT_BOTTOM)
