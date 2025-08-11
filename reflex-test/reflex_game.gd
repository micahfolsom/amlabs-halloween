extends Node2D

var NTARGETS: int = 4
var fLockedOut: bool = false
var LOCKOUT_TIME: float =  2.0 # sec
var PlayerScore: int = 0
var fHoleActive: Array = [false, false, false, false]
var LidPivots: Array = [null, null, null, null]

func _ready():
	$TargetRaiseTimer.connect("timeout", raise_target)
	fLockedOut = false
	PlayerScore = 0
	LidPivots = [$LidPivot1, $LidPivot2, $LidPivot3, $LidPivot4]

func _process(_delta):
	pass
	
func _input(_event):
	# Keyboard bindings: 1, 2, 3, 4 for the 4 holes
	if fLockedOut:
		return
		
	for i in range(NTARGETS):
		var action_name = "hole" + str(i + 1)
		if Input.is_action_just_pressed(action_name) and fHoleActive[i]:
			print("hole " + str(i) + " target hit")
			_score_hit()
			fHoleActive[i] = false
			# TODO: play hit animation, return lid when it's done
			_show_lid(i, true)
			return
			
	# TODO: figure out button mappings for test joystick setup
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		print('accept_pressed: ', accept_pressed)
		get_tree().change_scene_to_file("res://reflex_game.tscn")

func raise_target():
	print("raise")
	# Don't do anything if all holes are active
	var is_active = func(hole_flag):
		return hole_flag
	if fHoleActive.all(is_active):
		return
		
	# Pick a hole
	var itarget = randi() % NTARGETS
	while fHoleActive[itarget]:
		itarget = randi() % NTARGETS
	fHoleActive[itarget] = true
	print("chose target " + str(itarget))
	_show_lid(itarget, false)
	
	# Choose a target type
	if randf() < 0.25:
		print("scientist target")
	else:
		print("monster target")
	
	# TODO: move cover (need individual lids)
	
	# TODO: play monster animation1
	
	# TODO: begin raising monster

func _score_hit():
	PlayerScore += 1
	$CurrentScoreLabel.text = "Score: " + str(PlayerScore)
	
func _show_lid(ilid: int, toggle: bool):
	if toggle:
		LidPivots[ilid].rotation_degrees = 0
	else:
		LidPivots[ilid].rotation_degrees = -90
