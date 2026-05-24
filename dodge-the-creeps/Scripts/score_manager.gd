extends Node

var current_score: int = 0
var high_score: int = 0


func set_score(score: int) -> void:
	current_score = score
	
	if current_score > high_score:
		high_score = current_score
