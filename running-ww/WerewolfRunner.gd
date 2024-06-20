extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var left_pressed = Input.is_action_just_pressed("ui_left")
	if (left_pressed):
		print('left_pressed: ', left_pressed)
		frame = 1
	var right_pressed = Input.is_action_just_pressed("ui_right")
	if (right_pressed):
		print('right_pressed: ', right_pressed)
		frame = 2
