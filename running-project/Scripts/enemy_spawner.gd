extends Node2D


# 1. Export a reference slot to hold your inherited enemy scene
@export var enemy_scene: PackedScene = preload("res://Scenes/bringer_of_death.tscn")


func _on_timer_timeout() -> void:
	if not enemy_scene:
		print("Enemy scene not assigned!")
		return
	
	var new_enemy = enemy_scene.instantiate()

	new_enemy.global_position = global_position

	# attach it directly to the Main world node
	get_parent().add_child(new_enemy)
