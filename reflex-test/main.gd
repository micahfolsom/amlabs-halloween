# main.gd
extends Node2D

# ────────────────────────────────────────────────────────────────
# 1️⃣  Pre‑loaded character scenes
# ────────────────────────────────────────────────────────────────
@export var monster_scene   : PackedScene = preload("res://monster.tscn")
@export var scientist_scene : PackedScene = preload("res://scientist.tscn")

# ────────────────────────────────────────────────────────────────
# 2️⃣  Sound resources (exported so you can change the file if you wish)
# ────────────────────────────────────────────────────────────────
@export var monster_hit_stream   : AudioStream = preload("res://sounds/monster_hit.wav")
@export var scientist_hit_stream : AudioStream = preload("res://sounds/scientist_hit.wav")

# ────────────────────────────────────────────────────────────────
# 3️⃣  Game configuration
# ────────────────────────────────────────────────────────────────
const SPAWN_INTERVAL_MIN : float = 0.3   # seconds
const SPAWN_INTERVAL_MAX : float = 2.0   # seconds
const GAME_DURATION      : float = 15.0  # seconds

# ────────────────────────────────────────────────────────────────
# 4️⃣  Node references
# ────────────────────────────────────────────────────────────────
@onready var timer        : Timer      = $Timer          # 10‑s “game‑over” timer
@onready var score_label  : Label      = $UI/ScoreLabel
@onready var final_label  : Label      = $UI/FinalScoreLabel
@onready var spawn_points : Array[Node2D] = [
	$Spawn1, $Spawn2, $Spawn3, $Spawn4
]

# Audio players (children of this node)
@onready var monster_hit_player   : AudioStreamPlayer = $MonsterHitSound
@onready var scientist_hit_player : AudioStreamPlayer = $ScientistHitSound

# ────────────────────────────────────────────────────────────────
# 5️⃣  New nodes for the scientist‑banner
# ────────────────────────────────────────────────────────────────
# 5.1  Exported vars so you can tweak them in the editor
@export var scientist_banner_stream : AudioStream = preload("res://sounds/scientist_banner.wav")
@export var banner_duration          : float = 2.0   # seconds the banner stays visible

# 5.2  On‑ready references – they must exist in the scene
@onready var banner_label      : Label          = $UI/ScientistBannerLabel
@onready var banner_timer      : Timer          = $UI/ScientistBannerTimer
@onready var banner_sound_player : AudioStreamPlayer = $UI/ScientistBannerSound

# ────────────────────────────────────────────────────────────────
# 6️⃣  Game state
# ────────────────────────────────────────────────────────────────
var score          : int = 0
var _game_over     : bool = false
var _spawn_timer   : Timer
@export var debug_mode : bool = true   # Toggle debug prints

# ────────────────────────────────────────────────────────────────
# 7️⃣  Called when the scene enters the tree
# ────────────────────────────────────────────────────────────────
func _ready() -> void:
	randomize()

	# 7.1  Set the audio streams on the 1‑D players
	monster_hit_player.stream   = monster_hit_stream
	scientist_hit_player.stream = scientist_hit_stream

	# 7.2  Set the audio stream on the banner sound‑player
	banner_sound_player.stream = scientist_banner_stream

	# 7.3  Prepare the banner timer
	banner_timer.wait_time = banner_duration
	banner_timer.one_shot = true
	banner_timer.timeout.connect(_hide_scientist_banner)

	# 7.4  Keep the banner hidden at start
	banner_label.visible = false

	# 7.5  Game‑over timer
	timer.wait_time = GAME_DURATION
	timer.one_shot   = true
	timer.autostart  = true
	timer.timeout.connect(_on_game_over)

	# 7.6  Spawn timer (one‑shot – we restart it manually)
	_spawn_timer = Timer.new()
	add_child(_spawn_timer)
	_spawn_timer.one_shot  = true
	_spawn_timer.autostart = false
	_spawn_timer.timeout.connect(_on_spawn_timeout)

	# 7.7  First random spawn
	_spawn_timer.wait_time = randf_range(
		SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX
	)
	_spawn_timer.start()

	# 7.8  UI
	final_label.visible = false
	_update_score_label()

# ────────────────────────────────────────────────────────────────
# 8️⃣  Spawning logic
# ────────────────────────────────────────────────────────────────
func _on_spawn_timeout() -> void:
	if _game_over:
		return
	_spawn_random_character()
	_spawn_timer.wait_time = randf_range(
		SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX
	)
	_spawn_timer.start()

func _spawn_random_character() -> void:
	var free_spawns = spawn_points.filter(func(sp): return sp.get_child_count() == 0)
	if free_spawns.is_empty():
		return
	var sp = free_spawns.pick_random()
	var rnd = randi() % 2
	var character : Node2D = monster_scene.instantiate() if rnd == 0 else scientist_scene.instantiate()
	sp.add_child(character)

# ────────────────────────────────────────────────────────────────
# 9️⃣  Input – hit a spawn location
# ────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		if debug_mode:
			print("[INPUT] Key: %s" % event.as_text())
		_handle_hit_action("hit_spawn1", spawn_points[0])
		_handle_hit_action("hit_spawn2", spawn_points[1])
		_handle_hit_action("hit_spawn3", spawn_points[2])
		_handle_hit_action("hit_spawn4", spawn_points[3])

func _handle_hit_action(action_name : String, spawn_point : Node2D) -> void:
	if not Input.is_action_just_pressed(action_name):
		return

	if debug_mode:
		print("[HIT] Action detected: %s" % action_name)

	if spawn_point.get_child_count() == 0:
		if debug_mode:
			print("[HIT] No character at this spawn point.")
		return

	var child = spawn_point.get_child(0)
	var is_monster : bool = child.is_monster

	if debug_mode:
		print("[HIT] Hit a %s." % ("monster" if is_monster else "scientist"))

	# ----------►  Play hit SFX and update score ---------------
	if is_monster:
		score += 1
		monster_hit_player.play()        # <- Monster hit SFX
	else:
		score -= 1
		scientist_hit_player.play()      # <- Scientist hit SFX
		_show_scientist_banner()         # <── NEW: show banner

	if debug_mode:
		print("[SCORE] New score: %d" % score)

	child.queue_free()
	_update_score_label()

# ────────────────────────────────────────────────────────────────
# 10️⃣  New: Banner helpers
# ────────────────────────────────────────────────────────────────
func _show_scientist_banner() -> void:
	# If already visible, restart the timer so it stays for full duration
	banner_label.visible = true
	banner_sound_player.play()
	banner_timer.start()

func _hide_scientist_banner() -> void:
	banner_label.visible = false

# ────────────────────────────────────────────────────────────────
# 11️⃣  End of game
# ────────────────────────────────────────────────────────────────
func _on_game_over() -> void:
	_game_over = true
	_spawn_timer.stop()
	final_label.text = "Final Score: %d" % score
	final_label.visible = true

# ────────────────────────────────────────────────────────────────
# 12️⃣  Utility – keep score label updated
# ────────────────────────────────────────────────────────────────
func _update_score_label() -> void:
	score_label.text = "Score: %d" % score
