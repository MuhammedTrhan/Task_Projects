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
