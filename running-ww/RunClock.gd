extends Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var txt_to_format = "%d s"
	#$TimerLabel.set("theme_override_colors/font_color", Color(1.0,0.0,0.0,1.0))
	#$TimerLabel.add_theme_color_override("font_color", Color(1.0,0.0,0.0,1.0))
	if self.time_left > 6.0:
		$TimerLabel.self_modulate = Color(1.0,1.0,1.0,1.0)
	if self.time_left <= 6.0 and self.time_left > 3.0:
		$TimerLabel.self_modulate = Color(1.0,1.0,0.0,1.0)
	if self.time_left <= 3.0:
		$TimerLabel.self_modulate = Color(1.0,0.0,0.0,1.0)
	$TimerLabel.text = txt_to_format % time_left
