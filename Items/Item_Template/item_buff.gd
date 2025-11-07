class_name item_buff extends Node

var STAT: String = ""
var p = get_parent()

func _ready() -> void:
	STAT = setStat()
	p.set(STAT, p.get(STAT) + 1)
	

func setStat():
	return ""

func remove():
	p.set(STAT, p.get(STAT) - 1)
	queue_free()
