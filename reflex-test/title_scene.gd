extends Node2D

	
func _input(_event):
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		GameManager.change_to_scene_path("res://reflex_game.tscn")
		
	var coin_pressed = Input.is_action_just_pressed("coin_button")
	if coin_pressed:
		$CoinSound.play()
