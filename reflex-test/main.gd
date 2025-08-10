# main.gd
extends Node2D

# ------------------------------------------------------------------
# 1.  Pre‑loaded character scenes
# ------------------------------------------------------------------
@export var monster_scene   : PackedScene = preload("res://monster.tscn")
@export var scientist_scene : PackedScene = preload("res://scientist.tscn")

# ------------------------------------------------------------------
# 2.  Game configuration
# ------------------------------------------------------------------
const SPAWN_INTERVAL_MIN : float = 0.5   # seconds
const SPAWN_INTERVAL_MAX : float = 3.0   # seconds
const GAME_DURATION      : float = 10.0  # seconds

# ------------------------------------------------------------------
# 3.  Node references
# ------------------------------------------------------------------
@onready var timer       : Timer   = $Timer          # 10‑s “game‑over” timer
@onready var score_label : Label   = $UI/ScoreLabel
@onready var final_label : Label   = $UI/FinalScoreLabel
@onready var spawn_points : Array[Node2D] = [
	$Spawn1, $Spawn2, $Spawn3, $Spawn4
]

# ------------------------------------------------------------------
# 4.  Game state
# ------------------------------------------------------------------
var score          : int = 0
var _game_over     : bool = false
var _spawn_timer   : Timer

# ------------------------------------------------------------------
# 5.  Called when the scene enters the tree
# ------------------------------------------------------------------
func _ready() -> void:
	randomize()

	# 5.1  Game‑over timer
	timer.wait_time = GAME_DURATION
	timer.one_shot   = true
	timer.autostart  = true
	timer.timeout.connect(_on_game_over)

	# 5.2  Spawn timer (one‑shot – we restart it manually)
	_spawn_timer = Timer.new()
	add_child(_spawn_timer)
	_spawn_timer.one_shot  = true
	_spawn_timer.autostart = false
	_spawn_timer.timeout.connect(_on_spawn_timeout)

	# 5.3  First random spawn
	_spawn_timer.wait_time = randf_range(
		SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX
	)
	_spawn_timer.start()

	# 5.4  UI
	final_label.visible = false
	_update_score_label()

# ------------------------------------------------------------------
# 6.  Spawning logic – spawn **one** character at a random free
#     spawn point every random interval
# ------------------------------------------------------------------
func _on_spawn_timeout() -> void:
	if _game_over:
		return

	_spawn_random_character()

	# schedule next spawn with a new (random) interval
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

# ------------------------------------------------------------------
# 7.  Player input – “hit” a spawn location
# ------------------------------------------------------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		# Each action is linked to a spawn point in the editor
		_handle_hit_action("hit_spawn1", spawn_points[0])
		_handle_hit_action("hit_spawn2", spawn_points[1])
		_handle_hit_action("hit_spawn3", spawn_points[2])
		_handle_hit_action("hit_spawn4", spawn_points[3])

func _handle_hit_action(action_name : String, spawn_point : Node2D) -> void:
	if not Input.is_action_just_pressed(action_name):
		return

	if spawn_point.get_child_count() == 0:
		return  # nothing to hit

	var child = spawn_point.get_child(0)
	# `is_monster` is defined in Character.gd
	var is_monster : bool = child.is_monster

	if is_monster:
		score += 1
	else:
		score -= 1

	child.queue_free()
	_update_score_label()

# ------------------------------------------------------------------
# 8.  End of game
# ------------------------------------------------------------------
func _on_game_over() -> void:
	_game_over = true
	_spawn_timer.stop()
	final_label.text = "Final Score: %d" % score
	final_label.visible = true

# ------------------------------------------------------------------
# 9.  Utility – keep score label updated
# ------------------------------------------------------------------
func _update_score_label() -> void:
	score_label.text = "Score: %d" % score
