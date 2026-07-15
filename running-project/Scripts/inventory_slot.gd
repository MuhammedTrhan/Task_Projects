extends Panel

@onready var icon_rect: TextureRect = $Icon
@onready var name_label: Label = $NameLabel
@onready var quantity_label: Label = $QuantityLabel
@onready var highlight: ColorRect = $Highlight


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			PlayerInventory.set_active_slot(get_index())


func update_slot(item_data: ItemData, quantity: int):
	if item_data != null:
		icon_rect.texture = item_data.icon
		name_label.text = item_data.item_name
		quantity_label.text = str(quantity)
        
		# Hide quantity text if it's just 1 item (optional polish)
		quantity_label.visible = quantity > 1
	else:
		# Clear the slot visuals if it is empty
		icon_rect.texture = null
		name_label.text = ""
		quantity_label.text = ""
	

func set_highlighted(is_highlighted: bool):
	highlight.visible = is_highlighted