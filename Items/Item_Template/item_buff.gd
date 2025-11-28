class_name item_buff extends Node

var STAT: String = ""
@onready var p = get_parent()

func add():
	STAT = setStat()
	p.set(STAT, p.get(STAT) + 1)
	#print("setting ", STAT, " to ", p.get(STAT))
	

func setStat():
	return ""

func remove():
	p.set(STAT, p.get(STAT) - 1)
	#print("setting ", STAT, " to ", p.get(STAT))
	queue_free()
