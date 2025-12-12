extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body == Player:
		Global.shouldGenerate = true
		get_tree().change_scene_to_file("res://global.tscn")
