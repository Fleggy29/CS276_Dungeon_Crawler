extends Area2D

var pivot

func _ready() -> void:
	#hide()
	pivot = get_parent()
	
#func _process(delta: float) -> void:
	#pivot.rotation = Vector2(Global.player.position.x, -1).angle_to(get_global_mouse_position()) - PI/2
	#print("position", Vector2(Global.player.position.x, -1))
	#print("angle", Vector2(Global.player.position.x, -1).angle_to(get_global_mouse_position()) - PI/2)
