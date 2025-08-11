extends Node2D

	
func _input(_event):
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		get_tree().change_scene_to_file("res://reflex_game.tscn")
