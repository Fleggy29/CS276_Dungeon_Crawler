class_name MyLabel extends Area2D

signal buttonPress


@onready var textBox = $Label
@export var text: String 
@export var fontSize: int

func _ready() -> void:
	textBox.add_theme_font_size_override("font_size",fontSize)
	textBox.text = text
