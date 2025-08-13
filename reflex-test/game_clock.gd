extends Timer


func _ready() -> void:
	$GameClockLabel.text = "15 s"

func _process(_delta: float) -> void:
	if self.time_left > 10.0:
		$GameClockLabel.self_modulate = Color(1.0,1.0,1.0,1.0)
	if self.time_left <= 10.0 and self.time_left > 5.0:
		$GameClockLabel.self_modulate = Color(1.0,1.0,0.0,1.0)
	if self.time_left <= 5.0:
		$GameClockLabel.self_modulate = Color(1.0,0.0,0.0,1.0)
		
	$GameClockLabel.text = str(int(time_left)) + " s"
