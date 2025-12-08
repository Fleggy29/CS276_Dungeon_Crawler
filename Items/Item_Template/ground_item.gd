class_name GroundItem extends Area2D
signal ground_item_body_entered(body:Node2D, emitter:Node2D)
var highlightCol = Color(255,255,255,0)

#func _init(player:Player) -> void:
	#self.ground_item_body_entered.connect(player._on_ground_item_body_entered)

@onready var highlight = $Highlight

func _ready() -> void:
	updateHighlightColour()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("ground_item_body_entered", body, self)

func updateHighlightColour():
	var config = ConfigFile.new()
	var err = config.load("res://SaveData/settings.config")

	if err != OK:
		return

	highlightCol = config.get_value("Highlight", "item", highlightCol)
	highlight.color = highlightCol
