extends StaticBody2D

@export var required_key: ItemData
@export var loot_item: ItemData
@export var loot_quantity: int = 1

var is_open: bool = false


# This method is called directly by the player
func try_open(key_data: ItemData) -> bool:
	if is_open:
		return false # Already open

	if key_data == required_key:
		is_open = true
		
		# Trigger your AnimationPlayer here
		# Trigger your loot spawning logic here

		print("Chest opened!")
		return true
	else:
		print("You need the correct key to open this chest.")
		return false