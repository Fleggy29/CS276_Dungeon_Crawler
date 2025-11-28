extends Node2D


func _on_return_button_press() -> void:
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
