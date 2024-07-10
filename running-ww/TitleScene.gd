extends Node2D

#var run_scene = preload("res://running_scene.tscn").instantiate()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var up_pressed = Input.is_action_just_pressed("ui_up")
	if (up_pressed):
		print('up_pressed: ', up_pressed)
		get_tree().change_scene_to_file("res://score_scene.tscn")
	var right_pressed = Input.is_action_just_pressed("ui_right")
	if (right_pressed):
		print('right_pressed: ', right_pressed)
		get_tree().change_scene_to_file("res://running_scene.tscn")
