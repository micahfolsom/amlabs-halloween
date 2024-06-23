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
	$TimerLabel.text = txt_to_format % time_left
