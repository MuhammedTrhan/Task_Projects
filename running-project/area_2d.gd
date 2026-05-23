extends Area2D

var is_mouse_over: bool = false


func _on_mouse_exited() -> void:
	is_mouse_over = false


func _on_mouse_entered() -> void:
	is_mouse_over = true

func _input(event: InputEvent) -> void:
	# Check if the event is a mouse button click
	if event is InputEventMouseButton and event.pressed:
		# Check if it was the left mouse button
		if event.button_index == MOUSE_BUTTON_LEFT and is_mouse_over:
			modulate = Color.from_hsv(randf(), 0.8, 1.0)
