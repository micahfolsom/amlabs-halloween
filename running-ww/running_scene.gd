extends Node2D

var bgMusic

var time_begin
var time_delay
var playing

var LEFT_PRESS = 0
var RIGHT_PRESS = 1
var last_press = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	bgMusic = $BackgroundMusic
	time_begin = Time.get_ticks_usec()
	time_delay = 26.9
	playing = false
	#$Player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = (Time.get_ticks_usec() - time_begin) / 1000000.0
	
	if time >= time_delay and not playing:
		bgMusic.play()
		#playing = true
	

func _on_midi_player_midi_event(channel, event):
	print("hello")
