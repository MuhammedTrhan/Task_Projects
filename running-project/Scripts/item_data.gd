extends Resource
class_name ItemData

enum ItemType {
	CONSUMABLE,
	ACCUMULATE
}

@export var item_name: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var max_stack_size: int = 99
