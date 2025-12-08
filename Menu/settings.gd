extends Node2D

var playerColour = Color(255,255,255,0)
var editingPlayerColour = false
var enemyColour = Color(255,255,255,0)
var editingEnemyColour = false
var itemColour = Color(255,255,255,0)
var editingItemColour = false
var tempColourStore = Color(255,255,255,0)
@onready var colourPicker = $Colour

var config = ConfigFile.new()

func _ready() -> void:
	var err = config.load("res://SaveData/settings.config")

	if err != OK:
		return

	playerColour = config.get_value("Highlight", "player", playerColour)
	var textCol = playerColour
	textCol.a = 1
	$PlayerHighlight/Label.add_theme_color_override("font_color", textCol)
	enemyColour = config.get_value("Highlight", "enemy", enemyColour)
	textCol = enemyColour
	textCol.a = 1
	$EnemyHighlight/Label.add_theme_color_override("font_color", textCol)
	itemColour = config.get_value("Highlight", "item", itemColour)
	textCol = itemColour
	textCol.a = 1
	$ItemHighlight/Label.add_theme_color_override("font_color", textCol)
	print(playerColour)
	print(enemyColour)
	print(itemColour)
	

func _on_return_button_press() -> void:
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")


func _on_player_highlight_button_press() -> void:
	colourPicker.show()
	editingPlayerColour = true
	get_tree().paused = true


func _on_enemy_highlight_button_press() -> void:
	colourPicker.show()
	editingEnemyColour = true
	get_tree().paused = true


func _on_item_highlight_button_press() -> void:
	colourPicker.show()
	editingItemColour = true
	get_tree().paused = true


func _on_confirm_colour_button_press() -> void:
	if editingPlayerColour:
		playerColour = tempColourStore
		editingPlayerColour = false
		var textCol = playerColour
		textCol.a = 1
		$PlayerHighlight/Label.add_theme_color_override("font_color", textCol)
	elif editingEnemyColour:
		enemyColour = tempColourStore
		editingEnemyColour = false
		var textCol = enemyColour
		textCol.a = 1
		$EnemyHighlight/Label.add_theme_color_override("font_color", textCol)
	elif editingItemColour:
		itemColour = tempColourStore
		editingItemColour = false
		var textCol = itemColour
		textCol.a = 1
		$ItemHighlight/Label.add_theme_color_override("font_color", textCol)
	config.set_value("Highlight", "player", playerColour)
	config.set_value("Highlight", "enemy", enemyColour)
	config.set_value("Highlight", "item", itemColour)
	config.save("res://SaveData/settings.config")
	colourPicker.hide()
	await get_tree().create_timer(.5).timeout
	get_tree().paused = false


func _on_color_picker_color_changed(color: Color) -> void:
	tempColourStore = color
	tempColourStore.a = 100.0/255.0


func _on_clear_colour_button_press() -> void:
	tempColourStore = Color(255,255,255,0)
	_on_confirm_colour_button_press()
	colourPicker.hide()
