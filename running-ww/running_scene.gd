extends Node2D

const SAVE_PATH = "user://high_scores.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("RunClock").timeout.connect(_handle_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ww_power_level = $WerewolfRunner.power_level
	$PowerGauge.set_power_level(ww_power_level)

func _handle_game_over():
	print("GAME OVER!!!!")
	_save_latest_score()
	
	GameManager.change_to_scene_path("res://score_scene.tscn")

func _save_latest_score():
	var ww_node = get_node("WerewolfRunner")
	var nsteps = ww_node.steps_count
	var power_level = ww_node.power_level
	
	GameManager.add_new_high_score("AAA", nsteps, power_level, Time.get_unix_time_from_system())
