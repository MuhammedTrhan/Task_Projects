extends CharacterBody2D

const MAX_SPEED = 150.0
# How fast the player speeds up (pixels per second squared)
const ACCELERATION = 800.0
# How fast the player slides to a stop when letting go
const FRICTION = 600.0

# DASH MECHANIC VARIABLES
const DASH_IMPULSE = 500.0
var dash_velocity := Vector2.ZERO

var player_hurt: bool = false
var hurt_finished: bool = true
var is_invincible: bool = false
var is_dead: bool = false

var is_attacking: bool = false

@export var max_hp: float = 100.0
var current_hp: float = max_hp

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		execute_attack()
		print("Attack triggered!")
	
	if hurt_finished and not is_attacking:
		handle_movement(_delta)

	animation_manager()


func handle_movement(_delta: float) -> void:
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
	
	# 2. Listen for the Dash Trigger (Left Shift)
	if Input.is_action_just_pressed("dash"):
		# Determine dash direction: use current movement direction, or default forward
		var dash_direction = direction
		if dash_direction == Vector2.ZERO:
			# If standing still, use the direction the sprite container is facing
			dash_direction = Vector2($FlipPivot.scale.x, 0)
			
		# Overwrite current velocity with the massive explosion of speed!
		velocity = dash_direction.normalized() * DASH_IMPULSE

	move_and_slide()


func execute_attack() -> void:
	is_attacking = true

func animation_manager() -> void:
	if is_dead:
		$FlipPivot/AnimationPlayer.play("die")
		return
	
	if player_hurt:
		player_hurt = false
		$FlipPivot/AnimationPlayer.play("hurt")
		return
	
	# If the hurt animation is still playing, DO NOTHING.
	if not hurt_finished:
		return
	
	if is_attacking:
		$FlipPivot/AnimationPlayer.play("attack")
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

func _on_hurt_player() -> void:
	if is_invincible:
		return

	# Reset attack state so it doesn't get stuck if interrupted
	is_attacking = false

	take_damage(10) # Example damage value

	# If the hit killed the player, stop right here!
	if current_hp <= 0:
		return
	
	hurt_finished = false
	player_hurt = true

	is_invincible = true

	# Create a 1.5-second timer. When it finishes, turn invincibility off
	get_tree().create_timer(1.5).timeout.connect(func(): is_invincible = false)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		is_dead = false
		# Trigger your game over sequence or reload scene
		get_tree().reload_current_scene()

	elif anim_name == "hurt":
		hurt_finished = true
	
	elif anim_name == "attack":
		is_attacking = false
	

func take_damage(amount: float) -> void:
	current_hp -= amount
	print("Player HP remaining: ", current_hp)
	
	# Flash red, then fade to 50% opacity to show I-Frames
	var tween = create_tween()
	tween.tween_property($FlipPivot, "modulate", Color(5, 0.5, 0.5, 1), 0.1)
	tween.tween_property($FlipPivot, "modulate", Color(1, 1, 1, 0.5), 0.1) # Semi-transparent

	# Create another tween that restores full opacity after the 1-second I-Frame timer ends
	var restore_tween = create_tween()
	restore_tween.tween_interval(1.0) # Wait for 1 second
	restore_tween.tween_property($FlipPivot, "modulate", Color(1, 1, 1, 1), 0.1) # Back to normal
	
	if current_hp <= 0:
		die()
	
func die() -> void:
	is_dead = true


func _on_damage_area_area_entered(area: Area2D) -> void:
	# 3. Verify the parent actually has the method, then apply damage
	if area.has_method("take_damage"):
		area.take_damage(10.0)
