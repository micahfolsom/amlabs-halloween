extends Label

var DISPLAY_TIME: float = 1.0 # sec
var VEL_Y: float = 75.0 # pixels/sec
@onready var UpTimeSpentMoving: float = 0.0 # sec
@onready var DownTimeSpentMoving: float = 0.0 # sec
@onready var fUpMoving: bool = false
@onready var fDownMoving: bool = false
# relative to the parent label
var UP_Y_POS = -29.0
var DOWN_Y_POS = 21.0


func _ready() -> void:
	$ScoreUpLabel.visible = false
	$ScoreDownLabel.visible = false

func _process(delta: float) -> void:
	if fUpMoving:
		$ScoreUpLabel.position.y -= VEL_Y * delta
		UpTimeSpentMoving += delta
		if UpTimeSpentMoving >= DISPLAY_TIME:
			fUpMoving = false
			$ScoreUpLabel.visible = false
			UpTimeSpentMoving = 0.0
			$ScoreUpLabel.position.y = UP_Y_POS
	if fDownMoving:
		$ScoreDownLabel.position.y += VEL_Y * delta
		DownTimeSpentMoving += delta
		if DownTimeSpentMoving >= DISPLAY_TIME:
			fDownMoving = false
			$ScoreDownLabel.visible = false
			DownTimeSpentMoving = 0.0
			$ScoreDownLabel.position.y = DOWN_Y_POS

func add_score() -> void:
	# TODO: make copies and allow more than 1 at a time
	if fUpMoving:
		return
	$ScoreUpLabel.visible = true
	fUpMoving = true
	
func subtract_score() -> void:
	# TODO: make copies and allow more than 1 at a time
	if fDownMoving:
		return
	$ScoreDownLabel.visible = true
	fDownMoving = true
