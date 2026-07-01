extends CharacterBody2D

@export var max_hp: float = 100.0
@export var parry_cooldown: float = 1.0
@export var dash_cooldown: float = 1.0
@export var parry_speed: float = 50.0

const MAX_SPEED = 150.0
# How fast the player speeds up (pixels per second squared)
const ACCELERATION = 800.0
# How fast the player slides to a stop when letting go
const FRICTION = 600.0

# DASH MECHANIC VARIABLES
const DASH_IMPULSE = 500.0
var dash_velocity := Vector2.ZERO
var is_dashing: bool = false

var player_hurt: bool = false
var hurt_finished: bool = true
var is_invincible: bool = false
var is_dead: bool = false

var is_attacking: bool = false
var is_parrying: bool = false
var is_parry_starting: bool = false

var current_hp: float = max_hp
var cur_parry_cooldown: float = 0.0
var cur_dash_cooldown: float = 0.0


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		execute_attack()
		print("Attack triggered!")
		
	if (Input.is_action_just_pressed("parry") and not is_attacking and hurt_finished
		and not is_parry_starting and not is_parrying and cur_parry_cooldown <= 0):
			execute_parry()

	
	if hurt_finished and not is_attacking:
		handle_movement(_delta)
	
	if cur_parry_cooldown > 0:
		cur_parry_cooldown -= _delta

	if cur_dash_cooldown > 0:
		cur_dash_cooldown -= _delta

	animation_manager()


func handle_movement(_delta: float) -> void:
		# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction != Vector2.ZERO:
		var target_velocity: Vector2
		# move_and_slide is already framerate independent, so we don't need to use delta here.
		if is_parrying or is_parry_starting:
			# If parrying, move at a reduced speed
			target_velocity = direction * parry_speed
		else:
			# Normal movement
			target_velocity = direction * MAX_SPEED
		
		velocity = velocity.move_toward(target_velocity, ACCELERATION * _delta)
	else:
		# Instead of instantly stopping, smoothly slow down the player independent of framerate.
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * _delta)
	
	# 2. Listen for the Dash Trigger (Left Shift)
	if (Input.is_action_just_pressed("dash") and not is_dashing and not is_parrying
		and not is_parry_starting and cur_dash_cooldown <= 0):
			# Overwrite current velocity with the massive explosion of speed!
			velocity = execute_dash(direction)

	move_and_slide()


func execute_attack() -> void:
	is_attacking = true

func execute_dash(dash_direction: Vector2) -> Vector2:
	is_dashing = true

	if dash_direction == Vector2.ZERO:
		# If standing still, use the direction the sprite container is facing
		dash_direction = Vector2($FlipPivot.scale.x, 0)
		
	# Apply the dash impulse in the direction of movement
	dash_velocity = dash_direction.normalized() * DASH_IMPULSE

	return dash_velocity

func execute_parry() -> void:
	is_parry_starting = true
	

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
	
	# If the shield is rising, play startup
	if is_parry_starting:
		$FlipPivot/AnimationPlayer.play("parry_start")
		return

	# If the shield is up and active, play idle
	if is_parrying:
		$FlipPivot/AnimationPlayer.play("parry_idle")
		return
	
	if is_dashing:
		$FlipPivot/AnimationPlayer.play("dash")
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
	if is_invincible or is_parrying:
		return

	# Reset player states so it doesn't get stuck if interrupted
	is_attacking = false
	is_parry_starting = false
	is_parrying = false

	take_damage(10) # Example damage value

	# If the hit killed the player, stop right here!
	if current_hp <= 0:
		return
	
	hurt_finished = false
	player_hurt = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		is_dead = false
		# Trigger your game over sequence or reload scene
		get_tree().reload_current_scene()

	elif anim_name == "hurt":
		hurt_finished = true

		is_invincible = true

		# Create a 0.5-second timer. When it finishes, turn invincibility off
		get_tree().create_timer(0.5).timeout.connect(func(): is_invincible = false)

		var Invincibility_tween = create_tween()
		# Fade to 50% opacity to show I-Frames
		Invincibility_tween.tween_property($FlipPivot, "modulate", Color(1, 1, 1, 0.5), 0.1)

		# Create another tween that restores full opacity after the 1-second I-Frame timer ends
		var restore_tween = create_tween()
		restore_tween.tween_interval(0.5) # Wait for 0.5 second
		restore_tween.tween_property($FlipPivot, "modulate", Color(1, 1, 1, 1), 0.1) # Back to normal
	

	elif anim_name == "dash":
		is_dashing = false
		cur_dash_cooldown = dash_cooldown
	
	elif anim_name == "attack":
		is_attacking = false
	
	# PARRY LOGIC:
	elif anim_name == "parry_start":
		# The wind-up is over. Turn off the startup state...
		is_parry_starting = false
		# ...and immediately turn ON the mechanical parry window!
		is_parrying = true

	elif anim_name == "parry_idle":
		# The active parry animation finished. The parry is over.
		is_parrying = false
		cur_parry_cooldown = parry_cooldown
	

func take_damage(amount: float) -> void:
	current_hp -= amount
	print("Player HP remaining: ", current_hp)
	
	# Flash red
	var tween = create_tween()
	tween.tween_property($FlipPivot, "modulate", Color(1, 0, 0, 1), 0.1)

	if current_hp <= 0:
		die()
	
func die() -> void:
	is_dead = true


func _on_damage_area_area_entered(area: Area2D) -> void:
	# 3. Verify the parent actually has the method, then apply damage
	if area.has_method("take_damage"):
		area.take_damage(10.0)
