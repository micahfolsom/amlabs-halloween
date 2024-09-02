extends Sprite2D

var steps_count = 0
var power_level = 0

var max_sps = 0

# pl_threshholds[n] = sps means level n starts at sps steps per second
var pl_threshholds = [0, 3.5, 4.4, 5.5, 8.9, 10.1, 11.45]
var pl_steps_per_update = 7
#var pl_elapsed_time = 0.0
var pl_step_times = []

var LEFT_PRESS = 0
var RIGHT_PRESS = 1
var last_press = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pl_step_times = []
	power_level = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not get_parent().GAME_OVER and get_parent().GAME_START:
		var left_pressed = Input.is_action_just_pressed("ui_left")
		if (left_pressed) and (last_press != LEFT_PRESS):
			print('left_pressed: ', left_pressed)
			frame = 1
			steps_count += 1
			pl_step_times.push_back(Time.get_unix_time_from_system())
			print("Step times: ", pl_step_times)
			last_press = LEFT_PRESS
			$LeftPressSFX.playing = true
		var right_pressed = Input.is_action_just_pressed("ui_right")
		if (right_pressed) and (last_press != RIGHT_PRESS):
			print('right_pressed: ', right_pressed)
			frame = 2
			steps_count += 1
			pl_step_times.push_back(Time.get_unix_time_from_system())
			print("Step times: ", pl_step_times)
			last_press = RIGHT_PRESS
			$RightPressSFX.playing = true
		
		if 	pl_step_times.size() >= pl_steps_per_update:
			power_level = calc_power_level()
			pl_step_times = []
	
	var steps_string = "%02d steps"
	$StepsLabel.text = steps_string % steps_count

	#power_level = int(steps_count / POWER_LEVEL_DIVISOR)

func calc_power_level():
	var sum = 0
	var n_steps = pl_step_times.size();
	
	# handle trivial cases
	if n_steps == 0 or n_steps == 1:
		return 0
	
	# rms step time = sqrt( (1/n) * sum(dt^2) )
	for i in n_steps - 1:
		var step_time = pl_step_times[i+1] - pl_step_times[i]
		sum += step_time ** 2
		
	var steps_per_sec = 1 / sqrt(sum / n_steps)
	var new_power_level = 0
	
	if steps_per_sec >= pl_threshholds.back():
		new_power_level = pl_threshholds.size()
	else:
		for i in pl_threshholds.size():
			if steps_per_sec < pl_threshholds[i]:
				break
			else:
				new_power_level = i
	
	if steps_per_sec > max_sps:
		max_sps = steps_per_sec
	
	print("Steps per second: ", steps_per_sec, " => power level: ", new_power_level)
	
	return new_power_level
