extends Node2D


# 1. Export a reference slot to hold your inherited enemy scene
@export var enemy_scene: PackedScene = preload("res://Scenes/bringer_of_death.tscn")

@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	# Spawn an enemy immediately when the scene starts
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	if not enemy_scene:
		print("Enemy scene not assigned!")
		return
	
	var new_enemy = enemy_scene.instantiate()
	new_enemy.global_position = global_position

	# Give enemy random patrol points around the spawner
	var random_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	var random_dist = randf_range(80.0, 100.0)
	new_enemy.patrol_points = [
		random_dir * random_dist,
		- random_dir * random_dist
		] as Array[Vector2]

	if player:
		# Connect the enemy's hurt signal to a function that damages the player
		if new_enemy.has_signal("hurt_player") and player.has_method("_on_hurt_player"):
			new_enemy.hurt_player.connect(player._on_hurt_player)

	# attach it directly to the Main world node
	get_parent().add_child.call_deferred(new_enemy)
