extends CharacterBody2D

enum State {
	PATROL,
	CHASE
}

@export var chase_speed: float = 150.0
@export var patrol_speed: float = 100.0
@export var chase_threshold: float = 250.0
@export var patrol_points: Array[Vector2] = [Vector2(100, 0), Vector2(-100, 0)]

var current_state: State = State.PATROL
var player: CharacterBody2D = null

var absolute_patrol_points: Array[Vector2] = []
var current_point_index: int = 0
# How close counts as reaching the point
var arrival_threshold: float = 10.0

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
	
	move_and_slide()

	animation_manager()
		

func state_manager() -> State:
	if not player:
		return State.PATROL

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player < chase_threshold:
		return State.CHASE
	else:
		return State.PATROL


func handle_patrol(_delta: float) -> void:
	if absolute_patrol_points.is_empty():
		velocity = Vector2.ZERO
		return
	
	var target_point = absolute_patrol_points[current_point_index]

	var direction = global_position.direction_to(target_point)
	velocity = direction * patrol_speed

	# Check if we've reached the target point
	if global_position.distance_to(target_point) < arrival_threshold:
		current_point_index = (current_point_index + 1) % absolute_patrol_points.size()
	
func handle_chase(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * chase_speed


func animation_manager() -> void:
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
