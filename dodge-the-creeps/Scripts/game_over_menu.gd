extends Control

const GAME_SCENE_PATH = "res://Scenes/main_scene.tscn"
const MAIN_MENU_SCENE_PATH = "res://Scenes/main_menu.tscn"

@onready var score_label: Label = $ScoreLabel
@onready var high_score_label: Label = $HighScoreLabel


func _ready() -> void:
	# Get the current score and high score from the ScoreManager singleton
	var current_score = ScoreManager.current_score
	var high_score = ScoreManager.high_score
	
	# Update the labels with the scores
	score_label.text = "Score: " + str(current_score)
	high_score_label.text = "High Score: " + str(high_score)

func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
