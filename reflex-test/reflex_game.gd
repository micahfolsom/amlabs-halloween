extends Node2D

# Editor parameters
@export_group("Target Params")
@export var TargetRiseTime: float = 0.5
@export var TargetFallTime: float = 0.3
@export var TargetHitFallTime: float = 0.15

const NTARGETS: int = 4
@onready var PlayerScore: int = 0
@onready var fHoleActive: Array = [false, false, false, false]
@onready var fTargetHit: Array = [false, false, false, false]
@onready var LidPivots: Array = [$LidPivot1, $LidPivot2, $LidPivot3, $LidPivot4]
enum {TARGET_RAISING, TARGET_LOWERING}
@onready var TargetState: Array = [TARGET_RAISING,TARGET_RAISING,TARGET_RAISING,TARGET_RAISING]
@onready var TargetAnims: Array = [$Target1, $Target2, $Target3, $Target4]

@onready var TARGET_YBOTTOM: float = $TargetWindows/MovementWindow.position.y + $TargetWindows/MovementWindow.shape.size.y
@onready var TARGET_YTOP: float = $TargetWindows/MovementWindow.position.y

func _ready():
	$RaiseTimer.connect("timeout", raise_target)
	
func _physics_process(delta: float) -> void:
	# move targets if they are 1) active and 2) in the correct
	# state
	for i in range(NTARGETS):
		if fHoleActive[i]:
			if TargetState[i] == TARGET_RAISING:
				var velocity = (TARGET_YTOP - TARGET_YBOTTOM) / TargetRiseTime
				TargetAnims[i].translate(Vector2(0, velocity * delta))
				if TargetAnims[i].position.y <= $TargetWindows/MovementWindow.position.y:
					TargetAnims[i].position.y = $TargetWindows/MovementWindow.position.y
					TargetState[i] = TARGET_LOWERING
			elif TargetState[i] == TARGET_LOWERING:
				var velocity = (TARGET_YBOTTOM - TARGET_YTOP) / TargetFallTime
				TargetAnims[i].translate(Vector2(0, velocity * delta))
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
			_check_for_hit(i)
			return
			
func _check_for_hit(itarget: int) -> void:
	if not fHoleActive[itarget]:
		return
	_score_hit()
	TargetAnims[itarget].play("micah_hit")
	TargetState[itarget] = TARGET_LOWERING
	
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
