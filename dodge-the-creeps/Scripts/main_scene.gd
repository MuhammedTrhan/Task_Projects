extends Node2D

const ENEMY_SCENE = preload("res://Scenes/enemy.tscn")

@onready var spawn_timer: Timer = $SpawnTimer
@onready var enemy_locater: PathFollow2D = $SpawnPath/SpawnLocation
@onready var score_label: Label = $Score

var total_time: float = 0.0
var score: int = 0

var enemy_pool: Array = []

func _ready() -> void:
	# 2. Configure and start the timer
	spawn_timer.wait_time = 1.5 # Spawns an enemy every 1.5 seconds
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _process(delta: float) -> void:
	# 4. Increment the total time and update the score
	total_time += delta
	var current_score = int(total_time)

	if current_score != score:
		score = current_score
		score_label.text = str(score)

func _on_spawn_timer_timeout() -> void:
	# 1. Pick the start position along the path loop
	enemy_locater.progress_ratio = randf()
	var spawn_position = enemy_locater.global_position
	
	# 2. Pick a completely different random point along the path loop as the target destination
	enemy_locater.progress_ratio = randf()
	var target_position = enemy_locater.global_position
	
	var recycled_enemy = get_enemy_from_pool()

	if recycled_enemy:
		recycled_enemy.spawn_from_pool(spawn_position, target_position)
	else:
		var new_enemy = ENEMY_SCENE.instantiate()
		new_enemy.global_position = spawn_position
		new_enemy.target_position = target_position
		new_enemy.target_assigned = true
		
		enemy_pool.append(new_enemy)
		add_child(new_enemy)

# Gets an enemy from the pool if one is available, otherwise returns null
func get_enemy_from_pool() -> CharacterBody2D:
	for enemy in enemy_pool:
		if not enemy.is_active:
			return enemy
	return null