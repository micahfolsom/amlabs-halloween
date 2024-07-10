extends Timer

var TOTAL_TIME = 10
var time_elapsed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	var txt_to_format = "%d s"
	var time_left = TOTAL_TIME - time_elapsed
	#$TimerLabel.set("theme_override_colors/font_color", Color(1.0,0.0,0.0,1.0))
	#$TimerLabel.add_theme_color_override("font_color", Color(1.0,0.0,0.0,1.0))
	if time_left <= 5.0 and time_left > 3.0:
		$TimerLabel.self_modulate = Color(1.0,1.0,0.0,1.0)
	if time_left <= 3.0:
		$TimerLabel.self_modulate = Color(1.0,0.0,0.0,1.0)
	if time_left < 0:
		time_left = 0
	$TimerLabel.text = txt_to_format % time_left
