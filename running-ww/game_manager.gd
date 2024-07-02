extends Node

var isFullscreen

# Called when the node enters the scene tree for the first time.
func _ready():
	isFullscreen = false
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Toggle_Fullscreen"):
		isFullscreen = not isFullscreen
		
		if isFullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
