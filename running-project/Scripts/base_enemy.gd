extends CharacterBody2D

enum State {
	PATROL,
	CHASE
}

@export var speed: float = 150.0
@export var chase_threshold: float = 250.0

var current_state: State = State.PATROL
var player: CharacterBody2D = null

func _ready() -> void:
	# Find the player node
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	current_state = state_manager()

	match current_state:
		State.PATROL:
			handle_patrol(_delta)
		State.CHASE:
			handle_chase(_delta)
	
	move_and_slide()
		

func state_manager() -> State:
	if not player:
		return State.PATROL

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player < chase_threshold:
		return State.CHASE
	else:
		return State.PATROL


func handle_patrol(_delta: float) -> void:
	# Placeholder for patrol
	velocity = Vector2.ZERO


func handle_chase(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed