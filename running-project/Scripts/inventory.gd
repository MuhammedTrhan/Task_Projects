extends Node
class_name Inventory

# This array will hold our inventory slots.
# Each slot will look like this: {"item": ItemData, "quantity": int}
var slots: Array[Dictionary] = []
var max_slots: int = 20 # You can adjust your inventory size

func _ready():
	# Initialize the inventory with empty slots
	for i in range(max_slots):
		slots.append({"item": null, "quantity": 0})


func add_item(item_data: ItemData, quantity: int = 1) -> bool:
	if quantity <= 0:
		return true
	
	# 1. Try to add to an existing stack
	for slot in slots:
		if slot["item"] == item_data and slot["quantity"] < item_data.max_stack_size:
			var new_quantity: int = slot["quantity"] + quantity

			if new_quantity > item_data.max_stack_size:
				# Calculate remainder and set the slot to max stack size
				var overflow: int = new_quantity - item_data.max_stack_size
				slot["quantity"] = item_data.max_stack_size
				# Check again if there exists another stack for the same item by calling add_item recursively
				return add_item(item_data, overflow)

			else:
				slot["quantity"] = new_quantity
				return true

	# If not existing stack or no available space, find an empty slot
	for slot in slots:
		if slot["item"] == null:
			slot["item"] = item_data

			# Handle the case where the incoming quantity is larger than a full stack
			if quantity > item_data.max_stack_size:
				slot["quantity"] = item_data.max_stack_size
				var overflow: int = quantity - item_data.max_stack_size
				# Check again if there exists another stack for the same item by calling add_item recursively
				return add_item(item_data, overflow)
			else:
				slot["quantity"] = quantity
				return true

	# Inventory is full
	return false

func remove_item(slot_index: int, quantity: int = 1) -> bool:
	if slot_index < 0 or slot_index >= max_slots:
		return false

	var slot = slots[slot_index]
	if slot["item"] == null or quantity <= 0:
		return false

	if slot["quantity"] < quantity:
		return false # Not enough items to remove

	slot["quantity"] -= quantity

	# If the quantity drops to zero, clear the slot
	if slot["quantity"] == 0:
		slot["item"] = null

	return true

func get_item(slot_index: int) -> ItemData:
	if slot_index < 0 or slot_index >= max_slots:
		return null
	return slots[slot_index]["item"]

func get_inventory() -> Array[Dictionary]:
	return slots