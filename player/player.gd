class_name Player extends RefCounted
# Simple stat holder. Movement is choice-driven, not keyboard.

var id: int = 1
var hp: int = 3
var stat: int = 10

func _init(_id: int = 1) -> void:
	id = _id
