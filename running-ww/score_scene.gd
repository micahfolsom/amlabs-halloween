extends Node2D

const SAVE_PATH = "user://high_scores.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_high_scores()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		print('accept_pressed: ', accept_pressed)
		get_tree().change_scene_to_file("res://title_scene.tscn")

func _load_high_scores():
	print("LOADING")
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var j = JSON.new()
	print(file.get_as_text())
	var error = j.parse(file.get_as_text())
	if error == OK:
		var data = j.data
		print(data)
