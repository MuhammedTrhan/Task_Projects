extends Control

@export var inventory_backend: Inventory # Drag your backend node here in the Inspector
@export var slot_scene: PackedScene = preload("res://Scenes/inventory_slot.tscn")
@onready var grid: GridContainer = $Panel/GridContainer

func _ready():
	# Clear any dummy slots you might have placed in the editor
	for child in grid.get_children():
		child.queue_free()
        
	# Generate the visual slots based on your backend max_slots
	for i in range(inventory_backend.max_slots):
		var new_slot = slot_scene.instantiate()
		grid.add_child(new_slot)

	print("Inventory UI initialized with ", inventory_backend.max_slots, " slots.")
        
	update_inventory_ui()

func update_inventory_ui():
	var current_inventory = inventory_backend.get_inventory()
	var visual_slots = grid.get_children()
    
	# Loop through the backend array and update the visuals to match
	for i in range(current_inventory.size()):
		var slot_data = current_inventory[i]
		visual_slots[i].update_slot(slot_data["item"], slot_data["quantity"])