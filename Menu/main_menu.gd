extends Node2D


func _on_play_button_press() -> void:
	get_tree().change_scene_to_file("res://global.tscn")


func _on_settings_button_press() -> void:
	get_tree().change_scene_to_file("res://Menu/settings.tscn")


func _on_quit_button_press() -> void:
	get_tree().quit()
