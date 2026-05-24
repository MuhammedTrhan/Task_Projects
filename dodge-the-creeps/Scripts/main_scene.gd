extends Node2D

const GAME_OVER_SCENE_PATH = "res://Scenes/game_over_menu.tscn"
const PAUSE_SCENE_PATH = "res://Scenes/pause_menu.tscn"

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_locater: PathFollow2D = $SpawnPath/SpawnLocation
@onready var score_label: Label = $Score


var total_time: float = 0.0
# Time in seconds to reach the final difficulty
var max_diff_time: float = 100.0
var score: int = 0

var enemy_scenes: Array = [
	preload("res://Scenes/enemy_walk.tscn"),
	preload("res://Scenes/enemy_swim.tscn"),
	preload("res://Scenes/enemy_fly.tscn")
]

# Arrays representing spawn chances
var initial_weights: Array[float] = [0.7, 0.2, 0.1]
var final_weights: Array[float] = [0.2, 0.2, 0.6]
var current_weights: Array[float] = [0.0, 0.0, 0.0]

# Wait times for spawner
var init_spawn_time: float = 1.5
var final_spawn_time: float = 0.5

var enemy_pool: Array = []

func _ready() -> void:
	# Configure and start the timer
	spawn_timer.wait_time = init_spawn_time
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

	# Connect the pause menu signal
	$PauseMenu.game_paused.connect(on_game_paused)

func _process(delta: float) -> void:
	# 4. Increment the total time and update the score
	total_time += delta
	var current_score = int(total_time)

	if current_score != score:
		score = current_score
		score_label.text = str(score)


func _on_spawn_timer_timeout() -> void:
	var diff_factor = clamp(total_time / max_diff_time, 0.0, 1.0)

	spawn_timer.wait_time = lerp(init_spawn_time, final_spawn_time, diff_factor)
	
	# Calculate the current spawn weights based on the difficulty factor
	for i in range(enemy_scenes.size()):
		current_weights[i] = lerp(initial_weights[i], final_weights[i], diff_factor)

	# Pick a random enemy scene from your array
	var chosen_index = get_weighted_random_index(current_weights)
	var chosen_enemy = enemy_scenes[chosen_index]

	# 1. Pick the start position along the path loop
	enemy_locater.progress_ratio = randf()
	var spawn_position = enemy_locater.global_position
	
	# 2. Pick a completely different random point along the path loop as the target destination
	enemy_locater.progress_ratio = randf()
	var target_position = enemy_locater.global_position
	
	# Pass the chosen scene's file path to the pool check
	var recycled_enemy = get_enemy_from_pool(chosen_enemy.resource_path)

	if recycled_enemy:
		recycled_enemy.spawn_from_pool(spawn_position, target_position)
	else:
		var new_enemy = chosen_enemy.instantiate()
		new_enemy.global_position = spawn_position
		new_enemy.target_position = target_position
		new_enemy.target_assigned = true

		# Connect the player_hit signal to the _on_game_over function
		new_enemy.get_node("EnemyArea").player_hit.connect(_on_game_over)
		
		enemy_pool.append(new_enemy)
		add_child(new_enemy)

# Gets an enemy from the pool if one is available, otherwise returns null
func get_enemy_from_pool(target_path: String) -> CharacterBody2D:
	for enemy in enemy_pool:
		if not enemy.is_active and enemy.scene_file_path == target_path:
			return enemy
	return null

func get_weighted_random_index(weights: Array[float]) -> int:
	var random_weight = randf()
	var cumulative_weight = 0.0

	for i in range(weights.size()):
		cumulative_weight += weights[i]

		# If the random weight falls within the current cumulative weight, return this index
		if random_weight < cumulative_weight:
			return i

	return weights.size() - 1 # Fallback to the last index

func _on_game_over() -> void:
	print("Game Over!")

	spawn_timer.stop() # Stop spawning new enemies

	# Save the score to the ScoreManager singleton
	ScoreManager.set_score(score)

	get_tree().change_scene_to_file(GAME_OVER_SCENE_PATH) # Change to the game over scene


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_pause_button_pressed() -> void:
	$PauseMenu._toggle_pause()

func on_game_paused() -> void:
	# Save the score to the ScoreManager singleton
	ScoreManager.set_score(score)
