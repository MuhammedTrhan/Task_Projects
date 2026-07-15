extends StaticBody2D

@export var required_key: ItemData
@export var loot_item: ItemData
@export var loot_quantity: int = 1
@export var item_scene: PackedScene # Assign your PickupItem.tscn here
@export var drop_position_offset: Vector2 = Vector2(0, 40) # Adjust X and Y for final landing spot

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var is_open: bool = false


func _ready() -> void:
	# Set the default state upon instantiating the scene
	anim_player.play("idle")

# This method is called directly by the player
func try_open(key_data: ItemData) -> bool:
	if is_open:
		return false # Already open

	if key_data == required_key:
		is_open = true
		
		# Execute the opening animation, then automatically transition to the open_idle state
		anim_player.play("open")
		anim_player.queue("open_idle")

		spawn_loot()

		print("Chest opened!")
		return true
	else:
		print("You need the correct key to open this chest.")
		return false

	
func spawn_loot() -> void:
	if item_scene == null or loot_item == null:
		print("Error: item_scene or loot_item is not assigned.")
		return
	
	var loot_instance = item_scene.instantiate()
	loot_instance.item_resource = loot_item
	loot_instance.quantity = loot_quantity

	# Add to the current scene tree, not the chest itself
	get_tree().current_scene.get_node("Pickables").add_child(loot_instance)

	# Start at the chest's center
	loot_instance.global_position = global_position

	# Retrieve and disable the collision shape safely
	var collision_shape = loot_instance.get_node("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	
	# Calculate absolute positions for the arc
	var target_pos = global_position + drop_position_offset
	# Create an arc by finding the midpoint and subtracting Y (moving up in 2D space)
	var mid_pos = global_position.lerp(target_pos, 0.5) + Vector2(0, -50)

	var tween = create_tween()

	# Phase 1: Move up and towards midpoint
	tween.tween_property(loot_instance, "global_position", mid_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Phase 2: Move down to the target position
	tween.tween_property(loot_instance, "global_position", target_pos, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Phase 3: Re-enable collision so the player can pick it up
	if collision_shape:
		tween.tween_callback(func(): collision_shape.set_deferred("disabled", false))
