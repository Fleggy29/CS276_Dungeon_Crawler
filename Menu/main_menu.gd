extends Node2D

var config = ConfigFile.new()
var showResume: bool

func _ready() -> void:
	var err = config.load("res://SaveData/settings.config")

	if err != OK:
		return
		
	showResume = config.get_value("SaveState", "showResume")
	if showResume:
		$Resume.show()
		$Settings.position.y += 160
		$Quit.position.y += 160
	

func _on_play_button_press() -> void:
	config.set_value("SaveState", "showResume", true)
	runState.levelsCompleted = 0
	runState.enemiesKilled = 0
	runState.itemsPickedUp = 0
	runState.inventory = {}
	runState.inventorySize = 0
	runState.currentHP = runState.HPmax
	runState.currentMN = runState.MNmax

	config.save("res://SaveData/settings.config")
	Global.shouldGenerate = true
	get_tree().change_scene_to_file("res://global.tscn")


func _on_settings_button_press() -> void:
	get_tree().change_scene_to_file("res://Menu/settings.tscn")


func _on_quit_button_press() -> void:
	get_tree().quit()


func _on_resume_button_press() -> void:
	Global.shouldGenerate = false
	get_tree().change_scene_to_file("res://global.tscn")


func _on_scene_changed():
	var global = get_tree().current_scene
	if global and global.has_method("load_game"):
		global.load_game()
