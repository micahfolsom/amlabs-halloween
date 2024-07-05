extends Node2D

var MIN_POWER_LEVEL = 0
var MAX_POWER_LEVEL = 7

var power_level = 0

@onready var _animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if power_level < MAX_POWER_LEVEL:
		_animation_player.stop()
		$PowerGaugeIndicator.set_frame_coords(Vector2i(power_level, 0))
	else:
		_animation_player.play("MaxPower")

func set_power_level(target_power_level):
	if target_power_level >= MIN_POWER_LEVEL and target_power_level <= MAX_POWER_LEVEL:
		power_level = target_power_level
	else:
		print("Target Power Level Out of Range")
