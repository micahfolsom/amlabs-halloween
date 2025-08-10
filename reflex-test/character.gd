# character.gd
extends Node2D

# Public parameters (edit in the editor)
@export var rise_distance : float = 200.0
@export var rise_time    : float = 1.0
@export var fall_time    : float = 0.2
@export var is_monster : bool = true  

var _tween : Tween

func _ready() -> void:
	_start_animation()

func _start_animation() -> void:
	# Rise
	_tween = get_tree().create_tween()
	_tween.tween_property(self, "position:y", -rise_distance, rise_time)
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Fall back
	_tween.tween_property(self, "position:y", 0.0, fall_time)
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# When finished, free ourselves
	_tween.finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	# The character removes itself from the scene tree
	queue_free()
