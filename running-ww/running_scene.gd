extends Node2D

const SAVE_PATH = "user://high_scores.json"
var GAME_START = false
var GAME_OVER = false
var GAME_LENGTH = 10 # in seconds
var PITCH_RAMP_TIME = 1.0 # in seconds

@onready var BG_Music = $BackgroundMusic

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("ReadyTimer").timeout.connect(_handle_game_start)
	get_node("RunClock").timeout.connect(_handle_game_over)
	get_node("VictoryTimeout").timeout.connect(_handle_victory_timeout_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ww_power_level = $WerewolfRunner.power_level
	$PowerGauge.set_power_level(ww_power_level)
	_update_bg_music_pitch_for_power_level(ww_power_level, delta)
	
	if $ReadyTimer.time_left <= 1:
		$ReadyTimer/TimeToStartLabel.text = "Start in 1..."
	elif $ReadyTimer.time_left <= 2:
		$ReadyTimer/TimeToStartLabel.text = "Start in 2..."
	elif $ReadyTimer.time_left <= 3:
		$ReadyTimer/TimeToStartLabel.text = "Start in 3..."
		
func _handle_game_start():
	$RunClock.set_wait_time(GAME_LENGTH)
	$RunClock.start()
	$WerewolfRunner/StepsLabel.visible = true
	$ReadyTimer/TimeToStartLabel.visible = false
	$RunClock/TimerLabel.visible = true
	GAME_START = true

func _handle_game_over():
	print("GAME OVER!!!!", $WerewolfRunner.max_sps)
	_save_latest_score()
	
	GAME_OVER = true
	$WerewolfRunner.visible = false
	$VictoryWerewolf.visible = true
	$BackgroundMusic.playing = false
	$RunClock/TimerLabel.visible = false
	$VictoryMusic.play()
	$VictoryTimeout.start()
	
	
func _handle_victory_timeout_finished():
	print("Victory timeout!")
	GameManager.change_to_scene_path("res://score_scene.tscn")

func _save_latest_score():
	var ww_node = get_node("WerewolfRunner")
	var power_level = ww_node.power_level
	
	if power_level > $PowerGauge.MAX_POWER_LEVEL:
		power_level = $PowerGauge.MAX_POWER_LEVEL
		
	GameManager.nsteps = ww_node.steps_count
	GameManager.power_level = ww_node.power_level

func _update_bg_music_pitch_for_power_level(target_power_level, delta):
	var target_pitch = 1.0 + float(target_power_level**2)/240.0
	var new_pitch
	
	if BG_Music.pitch_scale >= target_pitch:
		new_pitch = target_pitch
	else:
		new_pitch = BG_Music.pitch_scale + (delta / PITCH_RAMP_TIME) * (float(target_power_level)/240)
	
	BG_Music.set_pitch_scale(new_pitch)
	
