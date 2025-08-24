extends Node2D

#const SAVE_PATH = "user://high_scores.json"
var scroll_lines_enabled = false
var line_height = 52
var line_scroll_speed = 2 # lines per second
var last_hs_index = 0
var num_initials_entered = 0
var initials_entered = ""

@onready var hsl_label = $HighScoreScroller/HighScoreListRichText


func _ready():
	$VictoryMusic.seek(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if scroll_lines_enabled and can_scroll():
		$HighScoreScroller.scroll_vertical += line_scroll_speed * line_height * delta
		
func _input(event):
	# Scrolling
	if scroll_lines_enabled:
		var accept_pressed = Input.is_action_just_pressed("ui_accept")
		if (accept_pressed):
			print('accept_pressed: ', accept_pressed)
			get_tree().change_scene_to_file("res://title_scene.tscn")
			
	# For initials input, only letters and numbers are valid
	if event is InputEventKey:
		if event.pressed:
			var kp_number = false
			var kp_letter = false
			# 48 = 0, 57 = 9
			if event.keycode >= 48 and event.keycode <= 57:
				kp_number = true
			# 65 = A, 90 = Z
			if event.keycode >= 65 and event.keycode <= 90:
				kp_letter = true
			if (kp_number or kp_letter) and (num_initials_entered < 3):
				print(event.as_text_key_label() + ' was pressed')
				$InputInitialsActual.text += event.as_text_key_label() + ' '
				initials_entered += event.as_text_key_label().to_upper()
				num_initials_entered += 1
	
	# 3 entered, confirm, then enable scroll
	if (not scroll_lines_enabled) and (num_initials_entered == 3):
		var accept_pressed = Input.is_action_just_pressed("ui_accept")
		if accept_pressed:
			_save_latest_score()
			hsl_label.text = ""
			update_hsl()
			line_height = hsl_label.get_content_height() / GameManager.high_scores.size()
			scroll_lines_enabled = true
			$HighScoreScroller.visible = true
			$InputInitialsActual.visible = false
			$InputInitialsLabel.visible = false


func can_scroll():
	var hss_scrolled_height = $HighScoreScroller.scroll_vertical
	
	# the 5 is a fudge factor
	if hss_scrolled_height <  line_height * (last_hs_index - 3) + 5: # hsl_content_height - hss_height:
		return true
	else:
		return false

func update_hsl():
	var idx = 0
	
	for hs_doc in GameManager.high_scores:
		var line_str = "%s : %d" % [hs_doc["initials"], hs_doc["score"]]
		
		if GameManager.hs_last_add_ts == hs_doc["ts"]:
			hsl_label.append_text("[pulse color=gold freq=10]" + line_str + "[/pulse]\n")
			last_hs_index = idx
		else:
			hsl_label.append_text(line_str + "\n")
		
		idx += 1

func _save_latest_score():	
	GameManager.add_new_high_score(initials_entered, GameManager.nPoints, GameManager.power_level, Time.get_unix_time_from_system())
