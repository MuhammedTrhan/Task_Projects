extends Node


# Load the custom images for the mouse cursor.
var arrow = load("res://Assets/StoneCursor/PNG/01.png")
var can_drop = load("res://Assets/StoneCursor/PNG/11.png")
var forbidden = load("res://Assets/StoneCursor/PNG/18.png")


func _ready():
	# Changes only the arrow shape of the cursor.
	# This is similar to changing it in the project settings.
	Input.set_custom_mouse_cursor(arrow)

	# Set the cursor for when dragging over a valid drop target
	Input.set_custom_mouse_cursor(can_drop, Input.CURSOR_CAN_DROP, Vector2(15, 0))

	# Set the cursor for when dragging over an invalid drop target
	Input.set_custom_mouse_cursor(forbidden, Input.CURSOR_FORBIDDEN, Vector2(15, 0))
