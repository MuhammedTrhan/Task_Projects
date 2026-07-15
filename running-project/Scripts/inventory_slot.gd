extends Panel

@onready var icon_rect: TextureRect = $Icon
@onready var name_label: Label = $NameLabel
@onready var quantity_label: Label = $QuantityLabel
@onready var highlight: ColorRect = $Highlight


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			PlayerInventory.set_active_slot(get_index())
		
func _get_drag_data(_at_position: Vector2) -> Variant:
	var current_item = PlayerInventory.get_item(get_index())

	# Don't allow dragging if the slot is empty
	if current_item == null:
		return null
	
	# Create a visual preview of the item being dragged
	var drag_preview = TextureRect.new()
	drag_preview.texture = current_item.icon
	drag_preview.custom_minimum_size = Vector2(40, 40)
	drag_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE

	# Wrap it in a Control to center it on the mouse pointer
	var drag_control = Control.new()
	drag_control.add_child(drag_preview)
	drag_control.position = - drag_preview.custom_minimum_size / 2

	set_drag_preview(drag_control)

	# Return the slot index as data payload
	return get_index()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	# Only allow dropping if the data is an integer (slot index)
	return typeof(data) == TYPE_INT

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var from_index = data
	var to_index = get_index()

	# Don't swap if they dropped it back on the exact same slot
	if from_index != to_index:
		PlayerInventory.swap_items(from_index, to_index)

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