extends CharacterBody2D


const SPEED = 300.0

@onready var animated_sprite: AnimatedSprite2D = $PlayerSprite


func _physics_process(_delta: float) -> void:
	# 1. Get input for all 4 directions at once
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Apply movement
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

		animated_sprite.stop()

	move_and_slide()
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	animated_sprite.flip_v = false

	if direction.x != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction.x < 0
	elif direction.y != 0:
		animated_sprite.play("up")
		animated_sprite.flip_v = direction.y > 0
	else:
		# Play the walk animation for a moment and stop, so player doesn't look up if idle.
		animated_sprite.play("walk")
		animated_sprite.stop()
