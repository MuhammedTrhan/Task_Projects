extends Node2D

@export var message: String = "Hello, World!"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(message)
	return