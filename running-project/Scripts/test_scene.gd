extends Node2D

@export var rotation_speed: float = 1.0

@onready var area_1 = $Area2D
@onready var area_2 = $Area2D2
@onready var area_3 = $Area2D3


func _process(delta: float) -> void:
	area_1.rotation += rotation_speed * delta
	area_2.rotation -= rotation_speed * delta
	area_3.rotation += rotation_speed / 2 * delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("a_pressed"):
		area_1.modulate = Color.from_hsv(randf(), 0.8, 1.0)

	if event.is_action_pressed("s_pressed"):
		area_2.modulate = Color.from_hsv(randf(), 0.8, 1.0)

	if event.is_action_pressed("d_pressed"):
		area_3.modulate = Color.from_hsv(randf(), 0.8, 1.0)
