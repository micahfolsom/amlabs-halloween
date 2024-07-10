extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("RunClock").timeout.connect(_handle_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var ww_power_level = $WerewolfRunner.power_level
	$PowerGauge.set_power_level(ww_power_level)

func _handle_game_over():
	print("GAME OVER!!!!")
	get_tree().change_scene_to_file("res://score_scene.tscn")
