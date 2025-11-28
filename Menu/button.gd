class_name MyButton extends Area2D

signal buttonPress

@onready var buttonOff = $ButtonOff
@onready var buttonOn = $ButtonOn
@onready var textBox = $Label
@export var text: String 

func _ready() -> void:
	textBox.text = text

func _on_mouse_entered() -> void:
	buttonOff.hide()
	buttonOn.show()
	textBox.position.y -= 8
	

func _on_mouse_exited() -> void:
	buttonOff.show()
	buttonOn.hide()
	textBox.position.y += 8
	

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if  event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("buttonPress")
