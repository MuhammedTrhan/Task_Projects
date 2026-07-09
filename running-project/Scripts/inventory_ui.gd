extends Control

@export var slot_scene: PackedScene = preload("res://Scenes/inventory_slot.tscn")
@onready var grid: GridContainer = $Panel/GridContainer

func _ready():
	PlayerInventory.inventory_updated.connect(update_slot)

	# Clear any dummy slots you might have placed in the editor
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
        
	# Generate the visual slots based on your backend max_slots
	for i in range(PlayerInventory.max_slots):
		var new_slot = slot_scene.instantiate()
		grid.add_child(new_slot)

	print("Inventory UI initialized with ", PlayerInventory.max_slots, " slots.")
        
	refresh_inventory_ui()

func refresh_inventory_ui():
	var current_inventory = PlayerInventory.get_inventory()
	var visual_slots = grid.get_children()
    
	# Loop through the backend array and update the visuals to match
	for i in range(current_inventory.size()):
		var slot_data = current_inventory[i]
		visual_slots[i].update_slot(slot_data["item"], slot_data["quantity"])
	
func update_slot(slot_index: int, item_data: ItemData, quantity: int):
	var visual_slots = grid.get_children()
	if slot_index >= 0 and slot_index < visual_slots.size():
		visual_slots[slot_index].update_slot(item_data, quantity)