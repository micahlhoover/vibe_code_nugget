extends CharacterBody2D

signal hit

const JUMP_VELOCITY = -400.0
const GRAVITY = 980.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

var is_dead = false

func _physics_process(delta):
	if is_dead:
		return
		
	print_debug("Player position set to: ", global_position)

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	# Only play the run animation when on the floor
	elif animated_sprite.animation != "run":
		animated_sprite.play("run")

	# Handle jump input (Spacebar or Mouse Click)
	if is_on_floor() and (Input.is_action_just_pressed("ui_accept")):
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump") # Use single-frame jump animation

	move_and_slide()
	global_position.x = 200

func die():
	if is_dead:
		return
	is_dead = true
	animated_sprite.play("dead")
	# Disable collision to prevent multiple 'hit' signals
	collision_shape.set_deferred("disabled", true)
	emit_signal("hit")

func reset_player():
	is_dead = false
	velocity = Vector2.ZERO
	position = Vector2(200, 500)
	animated_sprite.play("run")
	collision_shape.set_deferred("disabled", false)
