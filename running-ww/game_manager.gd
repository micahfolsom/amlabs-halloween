extends Node

const HIGH_SCORE_SAVE_PATH = "user://high_scores.json"

var high_scores = []
var hs_last_add_ts = 0
var nsteps = 0
var power_level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists(HIGH_SCORE_SAVE_PATH):
		load_high_scores()
	else:
		print("High score file not found at: ", HIGH_SCORE_SAVE_PATH)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Toggle_Fullscreen"):
		var windowMode = DisplayServer.window_get_mode()
		
		if windowMode == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func change_to_scene_path(resPath):
	get_tree().change_scene_to_file(resPath)

func sort_hs_descending(a, b):
	# if there's a tie, the earlier score wins
	if a["score"] == b["score"]:
		if a["power_level"] == b["power_level"]:
			return a["ts"] < b["ts"]
		else:
			return a["power_level"] > b["power_level"]
	else:
		return a["score"] > b["score"]

func hs_data_cb(hs_doc):
	if hs_doc.has("score"):
		hs_doc["score"] = int(hs_doc["score"])
	else:
		hs_doc["score"] = -1
	
	if not hs_doc.has("initials"):
		hs_doc["initials"] = ""
	
	if not hs_doc.has("power_level"):
		hs_doc["power_level"] = 0
	
	if not hs_doc.has("ts"):
		hs_doc["ts"] = 0
	
	return hs_doc

# less intensive append of new score to end of file
func add_new_high_score(initials,score,power_level,ts,sortOnAdd=true):
	var new_hs = {"score": int(score), "initials": initials, "power_level": int(power_level), "ts": int(ts)}
	hs_last_add_ts = int(ts)
	
	high_scores.push_back(new_hs)
	
	# @todo maybe optimization via insertion instead of a full sort?
	if sortOnAdd:
		high_scores.sort_custom(sort_hs_descending)
	
	JsonFileUtils.append_data_to_file(HIGH_SCORE_SAVE_PATH, new_hs)

# more expensive, will replace all high scores with what's
# in high_scores, useful if you want to store the list pre-sorted
func save_high_scores(sortBeforeSave=false):
	print("SAVING High Scores to file: ", HIGH_SCORE_SAVE_PATH)
	
	if sortBeforeSave == true:
		high_scores.sort_custom(sort_hs_descending)
	
	JsonFileUtils.replace_data_in_file(HIGH_SCORE_SAVE_PATH, high_scores)
	
	print("SAVED ", high_scores.size(), " high scores")

func load_high_scores(sortAfterLoad=true):
	print("LOADING High Scores from file: ", HIGH_SCORE_SAVE_PATH)
	
	# JSON parser casts all numbers to floats, so go through and convert them all to ints
	high_scores = JsonFileUtils.load_data_from_file(HIGH_SCORE_SAVE_PATH, hs_data_cb)
	
	# sort isn't stable...
	# so if there's a tie, there's no guarantee
	# about which score is first
	if sortAfterLoad:
		high_scores.sort_custom(sort_hs_descending)

#func formatted_score_str(initials, score):
	#return "%s : %d" % [initials, score]
