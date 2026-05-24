extends Control


const GAME_SCENE_PATH = "res://Scenes/main_scene.tscn"

@onready var high_score_label: Label = $HighScoreLabel


func _ready() -> void:
	# Get the high score from the ScoreManager singleton
	var high_score = ScoreManager.high_score
	
	# Update the label with the high score
	high_score_label.text = "High Score: " + str(high_score)

func _input(event: InputEvent) -> void:
	# Check for the "ui_accept" action
	if event.is_action_pressed("ui_accept"):
		# If the pause menu is currently visible, hide it and resume the game
		_on_start_button_pressed()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit()