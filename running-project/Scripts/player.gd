extends CharacterBody2D

@export var max_hp: float = 100.0
@export var parry_cooldown: float = 1.0
@export var dash_cooldown: float = 1.0
@export var parry_speed: float = 50.0
@export var charge_speed: float = 50.0
@export var max_charge: float = 1.0 # Maximum seconds the dash can be charged

const MAX_SPEED = 150.0
# How fast the player speeds up (pixels per second squared)
const ACCELERATION = 800.0
# How fast the player slides to a stop when letting go
const FRICTION = 600.0
const MIN_DASH_CHARGE = 0.3 # Minimum seconds the dash can be charged

# DASH MECHANIC VARIABLES
const DASH_IMPULSE = 450.0
var dash_velocity := Vector2.ZERO
var is_dashing: bool = false
var cur_charge: float = 0.0
var is_charging_dash: bool = false
var is_dash_burst_finished: bool = false # First acceleration animation is finshed

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

func _unhandled_input(event: InputEvent) -> void:
	# --- SCROLLING ---
	if event.is_action_pressed("scroll_up"):
		PlayerInventory.set_active_slot(PlayerInventory.active_slot_index - 1)
	elif event.is_action_pressed("scroll_down"):
		PlayerInventory.set_active_slot(PlayerInventory.active_slot_index + 1)

	# --- HOTKEYS ---
	if event.is_action_pressed("slot_0"):
		PlayerInventory.set_active_slot(0)
	elif event.is_action_pressed("slot_1"):
		PlayerInventory.set_active_slot(1)
	elif event.is_action_pressed("slot_2"):
		PlayerInventory.set_active_slot(2)
	elif event.is_action_pressed("slot_3"):
		PlayerInventory.set_active_slot(3)
	elif event.is_action_pressed("slot_4"):
		PlayerInventory.set_active_slot(4)
	elif event.is_action_pressed("slot_5"):
		PlayerInventory.set_active_slot(5)
	elif event.is_action_pressed("slot_6"):
		PlayerInventory.set_active_slot(6)
	
	# --- USING AND DROPPING ---
	var current_item = PlayerInventory.get_item(PlayerInventory.active_slot_index)

	if current_item != null:
		# CONSUME (E)
		if event.is_action_pressed("interract"):
			if current_item.item_type == ItemData.ItemType.CONSUMABLE:
				print("Ate the ", current_item.item_name, "! Delicious!")
				
				# Add healing logic here

				PlayerInventory.remove_item(PlayerInventory.active_slot_index, 1)
			else:
				print("Cannot consume ", current_item.item_name, ". It's not a consumable item.")

		# DROP (Q)
		elif event.is_action_pressed("drop_item"):
			print("Dropping item: ", current_item.item_name)
			PlayerInventory.remove_item(PlayerInventory.active_slot_index, 1)

			# Spawn a PickupItem scene at the player's position
		
func handle_movement(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("left", "right", "up", "down")

	if is_dashing:
		# If dashing, maintain the dash velocity in the direction player facing
		velocity = dash_velocity
	
	else:
		if direction != Vector2.ZERO:
			var target_velocity: Vector2

			# move_and_slide is already framerate independent, so we don't need to use delta here.
			if is_parrying or is_parry_starting:
				# If parrying, move at a reduced speed
				target_velocity = direction * parry_speed
			
			elif is_charging_dash:
				# If charging dash, move at a reduced speed
				target_velocity = direction * charge_speed

			else:
				# Normal movement
				target_velocity = direction * MAX_SPEED
			
			velocity = velocity.move_toward(target_velocity, ACCELERATION * _delta)

		else:
			if not is_dashing:
				# If no input, slow down the player smoothly
				# Instead of instantly stopping, smoothly slow down the player independent of framerate.
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION * _delta)
			else:
				# If dashing, maintain the dash velocity in the direction player facing
				direction = Vector2($FlipPivot.scale.x, 0)

				velocity = velocity.move_toward(direction.normalized() * DASH_IMPULSE, ACCELERATION * _delta)
	
	# CHARGED DASH MECHANIC
	# A. Start Charging
	if (Input.is_action_just_pressed("dash") and not is_dashing
		and not is_parrying and cur_dash_cooldown <= 0):
			is_charging_dash = true
			cur_charge = 0.0

	# B. Increase Charge while holding
	if is_charging_dash:
		if Input.is_action_pressed("dash"):
			cur_charge += _delta
			cur_charge = min(cur_charge, max_charge) # Cap the charge at the max value
            
		# C. Execute Dash on release
		if Input.is_action_just_released("dash"):
			is_charging_dash = false
			execute_dash(direction)

	move_and_slide()


func execute_attack() -> void:
	is_attacking = true

func execute_dash(dash_direction: Vector2) -> void:
	is_dashing = true
	is_invincible = true # DASH INVINCIBILITY
	is_dash_burst_finished = false

	# Calculate and lock in the dash direction ONCE
	if dash_direction == Vector2.ZERO:
		# If no direction is pressed, default to facing direction
		dash_direction = Vector2($FlipPivot.scale.x, 0)
	
	# Instantly snap the velocity vector to max speed!
	dash_velocity = dash_direction.normalized() * DASH_IMPULSE

	# Calculate dash time
	var dash_time = max(MIN_DASH_CHARGE, cur_charge)

	# Use a dynamic timer to end the dash exactly when the math says so
	get_tree().create_timer(dash_time).timeout.connect(func():
		is_dashing = false
		is_invincible = false
		cur_dash_cooldown = dash_cooldown
	)

func execute_parry() -> void:
	is_parry_starting = true
	

func animation_manager() -> void:
	if is_invincible:
		$FlipPivot.modulate = Color(1, 1, 1, 0.5) # Semi-transparent to indicate invincibility
	else:
		$FlipPivot.modulate = Color(1, 1, 1, 1) # Normal opacity
	
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
	
	# 1. While holding the charge button, just brace/idle
	if is_charging_dash:
		$FlipPivot/AnimationPlayer.play("charge_dash")
		return
	
	# 2. While physically moving during the dash...
	if is_dashing:
		# Play the explosive start...
		if not is_dash_burst_finished:
			$FlipPivot/AnimationPlayer.play("dash")
		# ...then seamlessly transition into the looping glide!
		else:
			$FlipPivot/AnimationPlayer.play("dash_idle")
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

	elif anim_name == "dash":
		is_dash_burst_finished = true
	
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
	PlayerInventory.clear_inventory() # Clear the inventory on death
	is_dead = true


func _on_damage_area_area_entered(area: Area2D) -> void:
	# 3. Verify the parent actually has the method, then apply damage
	if area.has_method("take_damage"):
		area.take_damage(10.0)


func _on_pickup_area_area_entered(area: Area2D) -> void:
	# Check if the area we collided with is actually an item
	if area is PickupItem:
		# Try to add it to the inventory backend
		var was_added = PlayerInventory.add_item(area.item_resource, area.quantity)

		# If the inventory had space and successfully added it, delete the physical item
		if was_added:
			area.queue_free()

	pass # Replace with function body.
