extends Area2D
class_name PlayerPickup

# Add a variable to track the currently overlapping interactive object
var nearby_interactable: Node = null


func _on_area_entered(area: Area2D) -> void:
	print("Area entered: ", area.name)
	
	# Check if the area we collided with is actually an item
	if area is PickupItem:
		# Try to add it to the inventory backend
		var was_added = PlayerInventory.add_item(area.item_resource, area.quantity)

		# If the inventory had space and successfully added it, delete the physical item
		if was_added:
			area.queue_free()

	elif area.name == "InterractionArea":
		# Retrieve the root node of the area we collided with
		var object = area.owner

		# Check if it has the try_open method before assigning it
		if object.has_method("try_open"):
			nearby_interactable = object

func _on_area_exited(area: Area2D) -> void:
	var object = area.owner
	# If the player leaves the interaction area, clear the reference
	if object == nearby_interactable:
		nearby_interactable = null
