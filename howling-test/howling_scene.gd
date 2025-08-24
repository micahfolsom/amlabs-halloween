extends Node2D

@onready var fGameStarted: bool = false
@onready var fGameFinished: bool = false

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	_update_timers()

func _on_countdown_timer_timeout() -> void:
	$GameTimer.start()
	fGameStarted = true
	$CountdownTimer/CountdownTimerLabel.text = "H O W L !!!"
	print("countdown finished")

func _on_game_timer_timeout() -> void:
	print("game finished")

func _update_timers() -> void:
	if not fGameStarted:
		$CountdownTimer/CountdownTimerLabel.text = str(int($CountdownTimer.time_left)) + "..."
	if fGameStarted and not fGameFinished:
		$GameTimer/GameTimerLabel.text = str(int($GameTimer.time_left)) + "..."
		if $GameTimer.time_left <= 3.5:
			$GameTimer/GameTimerLabel.self_modulate = Color(1.0, 1.0, 0.0, 1.0)
		if $GameTimer.time_left <= 2.0:
			$GameTimer/GameTimerLabel.self_modulate = Color(1.0, 0.0, 0.0, 1.0)
