extends Node2D

var levelsCompleted: int
var enemiesKilled: int
var itemsPickedUp: int

@onready var levelLabel = $Control/Levels
@onready var enemyLabel = $Control/Enemies
@onready var itemsLabel = $Control/Items

var isDead = false

var config = ConfigFile.new()

func _ready() -> void:
	hide()
	


func _on_player_dead(lvls: int, enms: int, items: int) -> void:
	if !isDead:
		levelsCompleted = lvls
		enemiesKilled = enms
		itemsPickedUp = items
		levelLabel.text += str(levelsCompleted)
		enemyLabel.text += str(enemiesKilled)
		itemsLabel.text += str(itemsPickedUp)
		show()
		isDead = true
		config.load("res://SaveData/settings.config")
		config.set_value("SaveState", "showResume", false)
		config.save("res://SaveData/settings.config")
		get_tree().paused = true
