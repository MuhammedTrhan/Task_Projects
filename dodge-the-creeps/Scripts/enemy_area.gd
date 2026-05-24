extends Area2D

signal player_hit


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.hide() # Hide the player

		player_hit.emit()
