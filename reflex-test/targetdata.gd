# Holds data for a target
class_name TargetData


extends Node

# Members
var active: bool = false
var hit: bool = false
var pivot: Node2D = null
var anim: AnimatedSprite2D = null
enum TargetState { Raising, Lowering }
static var SCI_PREFIX: Array[String] = ["alex", "tyler", "senia", "micah"]
static var MON_PREFIX: Array[String] = ["mummy", "cthulu"]
enum TargetType { Scientist, Monster }
var type: TargetType = TargetType.Monster
var anim_prefix: String = ""
var state: TargetState = TargetState.Raising

func _init():
	pass
