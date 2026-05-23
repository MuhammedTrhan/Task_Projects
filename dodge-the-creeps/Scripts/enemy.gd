extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $EnemySprite
@onready var damage_area: Area2D = $EnemyArea

const SPEED = 150.0

var target_position: Vector2 = Vector2.ZERO
var target_assigned: bool = false

# To track if the enemy is active or should be removed
var is_active: bool = true


func _physics_process(_delta: float) -> void:
	if is_active and target_assigned:
		# Find the direction vector towards the target position and normalize it
		var direction = (target_position - position).normalized()

		# Calculate the angle once
		var target_angle = direction.angle()

		# Rotate the enemy to face the direction it's moving
		sprite.rotation = target_angle
		damage_area.rotation = target_angle

		# Move the enemy towards the target position
		velocity = direction * SPEED
		move_and_slide()
		sprite.play("swim")

		# Check if the enemy has reached the target position
		if position.distance_to(target_position) < 10.0:
			recycle_to_pool()
	else:
		velocity = Vector2.ZERO


func recycle_to_pool() -> void:
	# Mark the enemy as inactive and hide it
	is_active = false
	target_assigned = false
	sprite.stop()
	hide()

	# Disable its inner Area2D collision shape so it stops hurting the player
	$EnemyArea/HitShape.disabled = true


func spawn_from_pool(spawn_pos: Vector2, target_pos: Vector2) -> void:
	# Set the enemy's position and target, then mark it as active
	global_position = spawn_pos
	target_position = target_pos
	target_assigned = true
	is_active = true
	show()

	# Enable its inner Area2D collision shape so it can hurt the player again
	$EnemyArea/HitShape.disabled = false
