extends Area2D

signal returned_to_pool(obstacle)
signal passed(obstacle)
signal touched(obstacle)

const SPEED = 300.0

func _on_body_entered(body):
	# When the player's body enters this area, call its 'die' function.
	if body is CharacterBody2D and body.has_method("die"):
		# Notify main that this obstacle touched the player (for SFX)
		emit_signal("touched", self)
		body.die()

# Called from Main.gd to position and activate the obstacle.
func start(pos: Vector2):
	global_position = pos
	visible = true
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1) # Fully opaque white
	$AnimatedSprite2D.scale = Vector2(1, 1) # Ensure it's not scaled to zero
	$AnimatedSprite2D.play("default")
#	$AnimatedSprite2D.play()
	set_physics_process(true)

func _physics_process(delta):
	print_debug("Barrel: ", global_position, " Z:", z_index, " Sprite Z:", $AnimatedSprite2D.z_index)
	position.x -= SPEED * delta
	print_debug("Barrel position set to: ", global_position)
	print("viewport size: ",get_viewport_rect().size)
	print("Obstacle visibility : ",visible)
	print("alpha : ",$AnimatedSprite2D.modulate.a)
	print("Children of obstacle:")
	for c in get_children():
		print(c.name, " | type:", c.get_class())
	if position.x < -200: # When off-screen
		set_physics_process(false)
		get_parent().remove_child(self)
		emit_signal("returned_to_pool", self)

	# Check if the obstacle has passed the player while the player is in the air.
	# Avoid double-scoring by setting a flag on the obstacle instance.
	if not has_meta("scored"):
		var parent = get_parent()
		if parent and parent.get_parent():
			var main = parent.get_parent()
			if main.has_node("Nugget"):
				var player = main.get_node("Nugget")
				# Player's x is fixed at ~200 in `Player.gd`; detect when obstacle crosses that x
				if global_position.x < player.global_position.x and not player.is_on_floor():
					set_meta("scored", true)
					emit_signal("passed", self)

func _init():
	# Initially disable physics process for all pooled instances
	set_physics_process(false)
