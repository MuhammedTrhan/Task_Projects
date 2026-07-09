extends Area2D
class_name PickupItem

@export var item_resource: ItemData
@export var quantity: int = 1

@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Automatically update the sprite to match the resource in the editor
	if item_resource and item_resource.icon:
		sprite.texture = item_resource.icon
