extends CharacterBody2D


const MAX_SPEED = 150.0
const ACCELERATION = 800.0 # How fast the player speeds up (pixels per second squared)
const FRICTION = 600.0 # How fast the player slides to a stop when letting go

var player_hit: bool = false
var hit_finished: bool = true


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		# move_and_slide is already framerate independent, so we don't need to use delta here.
		var target_velocity = direction * MAX_SPEED
		velocity = velocity.move_toward(target_velocity, ACCELERATION * _delta)
	else:
		# Instead of instantly stopping, smoothly slow down the player independent of framerate.
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * _delta)
	
	# Stun the player if they are hit by an enemy.
	if not hit_finished:
		velocity = Vector2.ZERO

	move_and_slide()

	animation_manager()


func animation_manager() -> void:
	if player_hit:
		player_hit = false
		$FlipPivot/AnimationPlayer.play("hit")
		return
	
	# If the hit animation is still playing, DO NOTHING.
	if not hit_finished:
		return

	# play the walk animation if we're moving, otherwise play idle
	if velocity.length() > 0:
		$FlipPivot/AnimationPlayer.play("walk")
	else:
		$FlipPivot/AnimationPlayer.play("idle")
	
	# flip the sprite based on movement direction
	if velocity.x != 0:
		if velocity.x < 0:
			$FlipPivot.scale.x = -1
		else:
			$FlipPivot.scale.x = 1

func _on_enemy_hit_player() -> void:
	hit_finished = false
	player_hit = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		hit_finished = true
