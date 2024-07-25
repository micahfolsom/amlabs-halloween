extends Node2D

#const SAVE_PATH = "user://high_scores.json"
var scroll_lines_enabled = false
var line_height = 52 # initial line height guess, will be calculated later
var line_scroll_speed = 2 # lines per second
var line_scroll_direction = 1 # -1 = scroll up, +1 = scroll down
var line_scroll_speed_fudger = 1.0 # scrolling up looks like it's faster than scrolling down
var line_scroll_pause = 2.0 # checked for every loop, for pausing at point
var line_scroll_direction_change_pause = 2.0
var hs_last_add_index = -1 # used with line height and delta to calculate how far to scroll per _process
var line_scroll_prev_scores_shown = 4.5 # how many hs above the highlighted one should be shown

@onready var hsl_label = $HighScoreScroller/HighScoreListRichText

# Called when the node enters the scene tree for the first time.
func _ready():
	hsl_label.text = "" # setting this way also clears all bbcode
	hs_last_add_index = -1 # this will be discovered during update_hsl
	update_hsl()
	
	line_height = hsl_label.get_content_height() / GameManager.high_scores.size()
	line_scroll_pause = 2.0
	scroll_lines_enabled = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		print('accept_pressed: ', accept_pressed)
		GameManager.change_to_scene_path("res://title_scene.tscn")
	
	if line_scroll_pause > 0:
		line_scroll_pause -= delta
	else:
		if scroll_lines_enabled and update_scroll():
			#print("scroll diff: ", line_scroll_direction * line_scroll_speed * line_height * delta * line_scroll_speed_fudger)
			$HighScoreScroller.scroll_vertical += line_scroll_direction * line_scroll_speed * line_height * delta * line_scroll_speed_fudger

func update_scroll():
	var hss_scrolled_height = $HighScoreScroller.scroll_vertical
	
	if hs_last_add_index < 0: # if no high score is being highlighted...
		#print("hs_last_add_index < 0: ", hs_last_add_index, " ", line_scroll_direction, " ", hss_scrolled_height)
		var hsl_content_height = hsl_label.get_content_height()
		var hss_height = $HighScoreScroller.size[1]
			
		if line_scroll_direction > 0:
			if hss_scrolled_height < hsl_content_height - hss_height:
				return true
			else:
				line_scroll_direction *= -1
				line_scroll_speed_fudger = 0.5
				line_scroll_pause = 2.0
				return true
		else:
			if hss_scrolled_height > 0:
				return true
			else:
				line_scroll_direction *= -1
				line_scroll_speed_fudger = 1.0
				line_scroll_pause = 2.0
				return true
	else:
		#print("hs_last_add_index >= 0")
		return hss_scrolled_height <  line_height * (hs_last_add_index - line_scroll_prev_scores_shown) # hsl_content_height - hss_height:

func update_hsl():
	var idx = 0
	
	for hs_doc in GameManager.high_scores:
		var line_str = "%s : %d - PL.%d" % [hs_doc["initials"], hs_doc["score"], hs_doc["power_level"]]
		
		if GameManager.hs_last_add_ts == hs_doc["ts"]:
			hsl_label.append_text("[pulse color=gold freq=10]" + line_str + "[/pulse]\n")
			hs_last_add_index = idx
		else:
			hsl_label.append_text(line_str + "\n")
		
		idx += 1
