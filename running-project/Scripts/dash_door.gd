extends StaticBody2D

# Drag your "open door" texture into this slot in the Inspector
@export var open_door_texture: Texture2D

var is_open: bool = false
# Variable to track the player when they are close
var player_in_zone: Node2D = null


func _physics_process(_delta: float) -> void:
	# If the player is in the zone, check if they are dashing
	if player_in_zone:
		if not is_open and player_in_zone.is_dashing:
			smash_door()

func _on_dash_detector_body_entered(body: Node2D) -> void:
	# Ignore if already open
	if is_open:
		return

	# When the player walks into the area, remember them
	if body.is_in_group("player"):
		player_in_zone = body
	

func _on_dash_detector_body_exited(body: Node2D) -> void:
	# Ignore if already open
	if is_open:
		return

	# When the player walks away, forget them
	if body == player_in_zone:
		player_in_zone = null
	

func smash_door() -> void:
	is_open = true

	# Change the picture to the broken/open door
	$LeftDoorWing.frame = 47
	$RightDoorWing.frame = 48

	# Disable the solid wall collision so the player flies right through
	# (We use set_deferred to safely turn off physics mid-frame)
	$CollisionShape2D.set_deferred("disabled", true)
