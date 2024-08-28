extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	var right_pressed = Input.is_action_just_pressed("ui_right")
	if (right_pressed):
		print('right_pressed: ', right_pressed)
		get_tree().change_scene_to_file("res://running_scene.tscn")
