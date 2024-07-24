extends Node2D

#const SAVE_PATH = "user://high_scores.json"
var scroll_lines_enabled = false
var line_height = 52
var line_scroll_speed = 2 # lines per second
var last_hs_index = 0

@onready var hsl_label = $HighScoreScroller/HighScoreListRichText

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hack for music continuity - can eventually move this (using
	# an Autoload node? or new scene?) so it's the same as the
	# one used in the running scene
	$VictoryMusic.seek(3)

	hsl_label.text = ""
	update_hsl()
	
	line_height = hsl_label.get_content_height() / GameManager.high_scores.size()
	scroll_lines_enabled = true
	
	#print(GameManager.high_scores, GameManager.hs_last_add_ts)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		print('accept_pressed: ', accept_pressed)
		get_tree().change_scene_to_file("res://title_scene.tscn")

	if scroll_lines_enabled and can_scroll():
		$HighScoreScroller.scroll_vertical += line_scroll_speed * line_height * delta

func can_scroll():
	#var hsl_content_height = hsl_label.get_content_height()
	#var hss_height = $HighScoreScroller.size[1]
	var hss_scrolled_height = $HighScoreScroller.scroll_vertical
	
	# the 5 is a fudge factor
	if hss_scrolled_height <  line_height * (last_hs_index - 3) + 5: # hsl_content_height - hss_height:
		return true
	else:
		return false

func update_hsl():
	var idx = 0
	
	for hs_doc in GameManager.high_scores:
		var line_str = "%s : %d - PL.%d" % [hs_doc["initials"], hs_doc["score"], hs_doc["power_level"]]
		
		if GameManager.hs_last_add_ts == hs_doc["ts"]:
			hsl_label.append_text("[pulse color=gold freq=10]" + line_str + "[/pulse]\n")
			last_hs_index = idx
		else:
			hsl_label.append_text(line_str + "\n")
		
		idx += 1
