extends CharacterBody2D


const SPEED = 150.0


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		# move_and_slide is already framerate independent, so we don't need to use delta here.
		velocity = direction * SPEED
	else:
		# Instead of instantly stopping, smoothly slow down the player independent of framerate.
		velocity = velocity.move_toward(Vector2.ZERO, SPEED * 10 * _delta)

	move_and_slide()

	animation_manager()


func animation_manager() -> void:
	# play the walk animation if we're moving, otherwise play idle
	# if velocity.length() > 0:
	# 	$FlipPivot/AnimationPlayer.play("walk")
	# else:
	# 	$FlipPivot/AnimationPlayer.play("idle")
	# flip the sprite based on movement direction
	if velocity.x != 0:
		if velocity.x < 0:
			$FlipPivot.scale.x = -1
		else:
			$FlipPivot.scale.x = 1