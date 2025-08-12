extends Timer


func _ready() -> void:
	$GameClockLabel.text = "15 s"


func _process(_delta: float) -> void:
	$GameClockLabel.text = str(int(time_left)) + " s"
