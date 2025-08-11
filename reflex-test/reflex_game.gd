extends Node2D

var NTARGETS: int = 4
var PlayerScore: int = 0
var fHoleActive: Array = [false, false, false, false]
var fTargetHit: Array = [false, false, false, false]
var LidPivots: Array = [null, null, null, null]
enum {TARGET_RAISING, TARGET_LOWERING}
var TargetState: Array = [TARGET_RAISING,TARGET_RAISING,TARGET_RAISING,TARGET_RAISING]
var TargetAnims: Array = [null, null, null, null]

var TARGET_YBOTTOM: float = 974.0
var TARGET_YTOP: float = 735.0
var TARGET_RAISE_TIME: float = 2.0
var TARGET_VELOCITY = (TARGET_YBOTTOM - TARGET_YTOP) / TARGET_RAISE_TIME

func _ready():
	$TargetRaiseTimer.connect("timeout", raise_target)
	PlayerScore = 0
	LidPivots = [$LidPivot1, $LidPivot2, $LidPivot3, $LidPivot4]
	TargetAnims = [$Target1, $Target2, $Target3, $Target4]
	
func _physics_process(delta: float) -> void:
	# move targets if they are 1) active and 2) in the correct
	# state
	for i in range(NTARGETS):
		if fHoleActive[i]:
			if TargetState[i] == TARGET_RAISING:
				TargetAnims[i].translate(Vector2(0, -TARGET_VELOCITY * delta))
				if TargetAnims[i].position.y <= TARGET_YTOP:
					TargetAnims[i].position.y = TARGET_YTOP
					TargetState[i] = TARGET_LOWERING
			elif TargetState[i] == TARGET_LOWERING:
				TargetAnims[i].translate(Vector2(0, TARGET_VELOCITY * delta))
				if TargetAnims[i].position.y >= TARGET_YBOTTOM:
					TargetAnims[i].position.y = TARGET_YBOTTOM
					TargetState[i] = TARGET_RAISING
					fHoleActive[i] = false
					_show_lid(i, true)
	
func _input(_event):
	# Keyboard bindings: 1, 2, 3, 4 for the 4 holes
	for i in range(NTARGETS):
		var action_name = "hole" + str(i + 1)
		if Input.is_action_just_pressed(action_name) and fHoleActive[i]:
			if not fHoleActive[i]:
				return
			print("hole " + str(i) + " target hit")
			_score_hit()
			#fHoleActive[i] = false
			# TODO: play hit animation, return lid when it's done
			#_show_lid(i, true)
			TargetAnims[i].play("micah_hit")
			TargetState[i] = TARGET_LOWERING
			return
			
	# TODO: figure out button mappings for test joystick setup
	var accept_pressed = Input.is_action_just_pressed("ui_accept")
	if (accept_pressed):
		print('accept_pressed: ', accept_pressed)

func raise_target():
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
		#TargetAnims[itarget].play("micah_raise")
	else:
		print("monster target")
	TargetAnims[itarget].play("micah_raise")
	

func _score_hit():
	PlayerScore += 1
	$CurrentScoreLabel.text = "Score: " + str(PlayerScore)
	$CurrentScoreLabel.add_score()
	$ScoreUpSFX.play()
	
func _score_error():
	PlayerScore -= 1
	$CurrentScoreLabel.text = "Score: " + str(PlayerScore)
	$CurrentScoreLabel.remove_score()
	$ScoreDownSFX.play()
	
func _show_lid(ilid: int, toggle: bool):
	if toggle:
		LidPivots[ilid].rotation_degrees = 0
	else:
		LidPivots[ilid].rotation_degrees = -90
