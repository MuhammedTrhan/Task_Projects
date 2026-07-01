extends CharacterBody2D

enum State {
	PATROL,
	CHASE,
	ATTACK
}

signal hurt_player

@export var chase_speed: float = 150.0
@export var patrol_speed: float = 100.0
@export var chase_threshold: float = 250.0
@export var attack_range: float = 30.0
@export var max_hp: float = 30.0

@export var patrol_points: Array[Vector2] = [Vector2(100, 0), Vector2(-100, 0)]

var current_hp: float = max_hp

var current_state: State = State.PATROL
var player: CharacterBody2D = null

var absolute_patrol_points: Array[Vector2] = []
var current_point_index: int = 0
# How close counts as reaching the point
var arrival_threshold: float = 10.0

var player_inside: bool = false
var attack_finished: bool = false
var player_hurt: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	# Find the player node
	player = get_tree().get_first_node_in_group("player")

	# Calculate absolute patrol points
	for point in patrol_points:
		absolute_patrol_points.append(global_position + point)

func _physics_process(_delta: float) -> void:
	current_state = state_manager()

	match current_state:
		State.PATROL:
			handle_patrol(_delta)
		State.CHASE:
			handle_chase(_delta)
		State.ATTACK:
			velocity = Vector2.ZERO

	move_and_slide()

	animation_manager()
		

func state_manager() -> State:
	if not player:
		return State.PATROL

	var distance_to_player = global_position.distance_to(player.global_position)
	
	if current_state == State.PATROL:
		if player_inside:
			return State.ATTACK
		if distance_to_player < chase_threshold:
			return State.CHASE
		else:
			return current_state

	elif current_state == State.CHASE:
		if player_inside:
			return State.ATTACK
		if distance_to_player >= chase_threshold:
			return State.PATROL
		else:
			return current_state

	elif current_state == State.ATTACK:
		if attack_finished:
			attack_finished = false
			player_hurt = false
			if distance_to_player < chase_threshold:
				return State.CHASE
			else:
				return State.PATROL
		else:
			return current_state
	else:
		return current_state


func handle_patrol(_delta: float) -> void:
	if absolute_patrol_points.is_empty():
		velocity = Vector2.ZERO
		return
	
	var target_point = absolute_patrol_points[current_point_index]
	nav_agent.target_position = target_point

	var next_path_position = nav_agent.get_next_path_position()

	var direction = global_position.direction_to(next_path_position)
	velocity = direction * patrol_speed

	# Check if we've reached the target point
	if global_position.distance_to(target_point) < arrival_threshold:
		current_point_index = (current_point_index + 1) % absolute_patrol_points.size()
	
func handle_chase(_delta: float) -> void:
	# Check if we can attack the player
	if player and global_position.distance_to(player.global_position) < attack_range:
		velocity = Vector2.ZERO

		# even if it is close enough, force the enemy to face the player
		if player.global_position.x < global_position.x:
			$FlipPivot.scale.x = 1
		else:
			$FlipPivot.scale.x = -1
			
		return
	
	# Feed the player's position to the navigation agent
	nav_agent.target_position = player.global_position

	# Get the instructions from the navigator.
	var next_path_position = nav_agent.get_next_path_position()

	# Calculate the direction towards the next path position
	var direction = global_position.direction_to(next_path_position)
	velocity = direction * chase_speed


func animation_manager() -> void:
	if current_state == State.ATTACK:
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
			$FlipPivot.scale.x = 1
		else:
			$FlipPivot.scale.x = -1


func trigger_atack_damage() -> void:
	if player_inside and not player_hurt:
		emit_signal("hurt_player")
		player_hurt = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# After the attack animation finishes, return to patrolling
	if anim_name == "attack":
		attack_finished = true


func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and not player_inside:
		player_inside = true


func _on_damage_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player") and player_inside:
		player_inside = false


func take_damage(amount: float) -> void:
	current_hp -= amount
	print("Enemy HP remaining: ", current_hp)
    
	# Visible feedback flash
	var tween = create_tween()
	tween.tween_property($FlipPivot, "modulate", Color(5, 0.5, 0.5), 0.1)
	tween.tween_property($FlipPivot, "modulate", Color(1, 1, 1), 0.1)
    
	if current_hp <= 0:
		queue_free() # Enemy dies