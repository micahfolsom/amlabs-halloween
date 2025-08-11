extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _input(_event):
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		print('accept_pressed: ', accept_pressed)
		get_tree().change_scene_to_file("res://reflex_game.tscn")
