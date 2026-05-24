extends CanvasLayer

const MAIN_MENU_SCENE_PATH = "res://Scenes/main_menu.tscn"

@onready var high_score_label: Label = $HighScoreLabel

signal game_paused
signal game_resumed


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide it when the game begins
	hide()


func _input(event: InputEvent) -> void:
	# Check for the "ui_cancel" action
	if event.is_action_pressed("ui_cancel"):
		# If the pause menu is currently visible, hide it and resume the game
		_toggle_pause()

func _toggle_pause() -> void:
	# Flip the tree's pause state
	get_tree().paused = not get_tree().paused

	# Show or hide the pause menu based on the new pause state
	var is_paused = get_tree().paused

	if is_paused:
		game_paused.emit()

		# Update the high score label when the menu is shown
		var high_score = ScoreManager.high_score
		high_score_label.text = "High Score: " + str(high_score)
	else:
		game_resumed.emit()
	
	visible = is_paused

func _on_continue_button_pressed() -> void:
	_toggle_pause()


func _on_restart_button_pressed() -> void:
	# Unfreeze the game first
	get_tree().paused = false

	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	# Unfreeze the game first
	get_tree().paused = false

	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
