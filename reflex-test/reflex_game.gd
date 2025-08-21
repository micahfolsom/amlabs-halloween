extends Node2D

# Editor parameters
@export_group("Target Params")
@export var TargetRiseTime: float = 0.5
@export var TargetFallTime: float = 0.3
@export var TargetHitFallTime: float = 0.15
@export var ScientistProbability: float = 0.25

const NTARGETS: int = 4
@onready var fGameFinished: bool = false

@onready var PlayerScore: int = 0

@onready var LidPivots: Array = [$LidPivot1, $LidPivot2, $LidPivot3, $LidPivot4]
@onready var TargetAnims: Array = [$Target1, $Target2, $Target3, $Target4]
@onready var Targets: Array[TargetData] = [null, null, null, null]

@onready var TARGET_YBOTTOM: float = $TargetWindows/MovementWindow.position.y + $TargetWindows/MovementWindow.shape.size.y
@onready var TARGET_YTOP: float = $TargetWindows/MovementWindow.position.y

func _populate_target_data() -> void:
	for i in range(NTARGETS):
		Targets[i] = TargetData.new() as TargetData
		Targets[i].pivot = LidPivots[i]
		Targets[i].anim = TargetAnims[i]

func _ready():
	$RaiseTimer.connect("timeout", raise_target)
	_populate_target_data()
	
func _physics_process(delta: float) -> void:
	# move targets if they are 1) active and 2) in the correct
	# state
	for i in range(NTARGETS):
		if Targets[i].active:
			if Targets[i].state == TargetData.TargetState.Raising:
				var velocity = (TARGET_YTOP - TARGET_YBOTTOM) / TargetRiseTime
				Targets[i].anim.translate(Vector2(0, velocity * delta))
				if Targets[i].anim.position.y <= $TargetWindows/MovementWindow.position.y:
					Targets[i].anim.position.y = $TargetWindows/MovementWindow.position.y
					Targets[i].state = TargetData.TargetState.Lowering
			elif Targets[i].state == TargetData.TargetState.Lowering:
				var velocity = (TARGET_YBOTTOM - TARGET_YTOP) / TargetFallTime
				if Targets[i].hit:
					velocity = (TARGET_YBOTTOM - TARGET_YTOP) / TargetHitFallTime
				Targets[i].anim.translate(Vector2(0, velocity * delta))
				if Targets[i].anim.position.y >= TARGET_YBOTTOM:
					Targets[i].anim.position.y = TARGET_YBOTTOM
					Targets[i].state = TargetData.TargetState.Raising
					Targets[i].active = false
					_show_lid(i, true)
	
func _input(_event):
	if fGameFinished:
		# TODO: go to score screen
		return
	# Keyboard bindings: 1, 2, 3, 4 for the 4 holes
	for i in range(NTARGETS):
		var action_name = "hole" + str(i + 1)
		if Input.is_action_just_pressed(action_name) and Targets[i].active:
			_check_for_hit(i)
			return
			
func _check_for_hit(itarget: int) -> void:
	if not Targets[itarget].active:
		return
	if fGameFinished:
		return
		
	if _target_is_in_hitbox(itarget):
		if Targets[itarget].type == TargetData.TargetType.Monster:
			_score_hit()
			Targets[itarget].anim.self_modulate = Color(0.5, 1.0, 0.5, 1.0)
		else:
			_score_error()
			Targets[itarget].anim.self_modulate = Color(1.0, 0.5, 0.5, 1.0)
		Targets[itarget].anim.play(Targets[itarget].anim_prefix + "_hit")
		Targets[itarget].state = TargetData.TargetState.Lowering
		Targets[itarget].hit = true
	
func _target_is_in_hitbox(itarget: int) -> bool:
	# y is up; the base y-coord of the target sprite needs to pass the "top"
	# (down in this case) of the hitbox
	var hitbox_y_thresh = $TargetWindows/Hitbox.position.y + $TargetWindows/Hitbox.shape.size.y
	if Targets[itarget].anim.position.y <= hitbox_y_thresh:
		return true
	else:
		return false

	
func raise_target():
	if fGameFinished:
		return
	# Don't do anything if all holes are active
	var is_active = func(hole_flag):
		return hole_flag
	if [Targets[0].active, Targets[1].active, Targets[2].active, Targets[3].active].all(is_active):
		return
		
	# Pick a hole
	var itarget = randi() % NTARGETS
	while Targets[itarget].active:
		itarget = randi() % NTARGETS
	Targets[itarget].active = true
	print("chose hole " + str(itarget))
	
	
	_show_lid(itarget, false)
	Targets[itarget].hit = false
	Targets[itarget].anim.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Choose a target type
	if randf() < ScientistProbability:
		print("scientist target")
		# pick a random scientist
		var isci: int = randi() % TargetData.SCI_PREFIX.size()
		Targets[itarget].anim.play(TargetData.SCI_PREFIX[isci] + "_raise")
		Targets[itarget].anim_prefix = TargetData.SCI_PREFIX[isci]
		Targets[itarget].type = TargetData.TargetType.Scientist
	else:
		print("monster target")
		var imon: int = randi() % TargetData.MON_PREFIX.size()
		Targets[itarget].anim.play(TargetData.MON_PREFIX[imon] + "_raise")
		Targets[itarget].anim_prefix = TargetData.MON_PREFIX[imon]
		Targets[itarget].type = TargetData.TargetType.Monster
	

func _score_hit():
	PlayerScore += 1
	$CurrentScoreLabel.text = "Score: " + str(PlayerScore)
	$CurrentScoreLabel.add_score()
	$ScoreUpSFX.play()
	
func _score_error():
	PlayerScore -= 1
	$CurrentScoreLabel.text = "Score: " + str(PlayerScore)
	$CurrentScoreLabel.subtract_score()
	$ScoreDownSFX.play()
	
func _show_lid(ilid: int, toggle: bool):
	if toggle:
		LidPivots[ilid].rotation_degrees = 0
	else:
		LidPivots[ilid].rotation_degrees = -90
		

func _on_game_clock_timeout() -> void:
	print("game finished")
	fGameFinished = true
	$GameClock/GameClockLabel.hide()
	$GameClock/GameFinishedLabel.show()
