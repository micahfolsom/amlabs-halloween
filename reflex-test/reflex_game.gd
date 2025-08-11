extends Node2D

var NTARGETS = 4
var fLockedOut = false
var LOCKOUT_TIME =  2.0 # sec
var PlayerScore = 0
var fHoleActive = [false, false, false, false]

func _ready():
	$TargetRaiseTimer.connect("timeout", raise_target)
	fLockedOut = false
	PlayerScore = 0

func _process(_delta):
	pass
	
func _input(_event):
	# Keyboard bindings: 1, 2, 3, 4 for the 4 holes
	if fLockedOut:
		return
		
	for i in range(4):
		var action_name = "hole" + str(i + 1)
		if Input.is_action_just_pressed(action_name) and fHoleActive[i]:
			print("hole " + str(i) + " target hit")
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
	
	# Choose a target type
	if randf() < 0.25:
		print("scientist target")
	else:
		print("monster target")
	
	# TODO: move cover (need individual lids)
	
	# TODO: play monster animation
	
	# TODO: begin raising monster
