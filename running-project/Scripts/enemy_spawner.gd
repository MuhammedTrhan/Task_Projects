extends Node2D


# 1. Export a reference slot to hold your inherited enemy scene
@export var enemy_scene: PackedScene = preload("res://Scenes/bringer_of_death.tscn")

@onready var player = get_tree().get_first_node_in_group("player")


func _on_timer_timeout() -> void:
	if not enemy_scene:
		print("Enemy scene not assigned!")
		return
	
	var new_enemy = enemy_scene.instantiate()
	new_enemy.global_position = global_position

	if player:
		# Connect the enemy's hit signal to a function that damages the player
		if new_enemy.has_signal("hit_player") and player.has_method("_on_enemy_hit_player"):
			new_enemy.hit_player.connect(player._on_enemy_hit_player)

	# attach it directly to the Main world node
	get_parent().add_child(new_enemy)
