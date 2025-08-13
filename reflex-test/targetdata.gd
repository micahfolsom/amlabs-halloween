# Holds data for a target
class_name TargetData


extends Node

# Members
var active: bool = false
var hit: bool = false
var pivot: Node2D = null
var anim: AnimatedSprite2D = null
enum TargetState { Raising, Lowering }
var state: TargetState = TargetState.Raising

func _init():
	pass
