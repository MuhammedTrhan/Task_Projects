extends Area2D

enum State {
	IDLE,
	BURNING,
	WET,
	CARBONIZED
}

var state: State = State.IDLE
@onready var state_label: Label = %Label

var burn_duration: float = 5.0 # Duration of the burning effect in seconds.
var burn_progress: float = 0.0

var wet_duration: float = 3.0 # Duration of the wet effect in seconds.
var wet_progress: float = 0.0

var ignited_requested: bool = false
var water_splashed: bool = false


func _process(delta: float) -> void:
	state_handler(delta)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			ignited_requested = true
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			water_splashed = true


func state_handler(delta: float) -> void:
	match state:
		State.IDLE:
			modulate = Color(1, 1, 1) # Change color to white when idle.
			state_label.text = "State: IDLE\nPress SPACE to ignite"

			if ignited_requested:
				state = State.BURNING
				burn_progress = 0.0

				ignited_requested = false

		State.BURNING:
			modulate = Color(1, 0, 0) # Change color to red when ignited.

			burn_progress += delta / burn_duration

			state_label.text = "State: BURNING\nClick to splash water\nBurning progress: " + str(int(burn_progress * 100)) + "%"

			if water_splashed:
				state = State.WET
				wet_progress = 0.0

				water_splashed = false
			
			if burn_progress >= 1.0:
				state = State.CARBONIZED

		State.WET:
			modulate = Color(0, 0, 1) # Change color to blue when wet.
			state_label.text = "State: WET\nWait for it to dry"

			wet_progress += delta / wet_duration
			if wet_progress >= 1.0:
				state = State.IDLE
		
		State.CARBONIZED:
			modulate = Color(0, 0, 0) # Change color to black when carbonized.
			state_label.text = "State: CARBONIZED\nIt's too late to save it"
