extends Control


const GAME_SCENE_PATH = "res://Scenes/main_scene.tscn"


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)


func _on_quit_button_pressed() -> void:
	get_tree().quit()