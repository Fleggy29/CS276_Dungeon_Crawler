class_name Global extends Node

static var player = null
const TILESIZE = 64
@onready var camera := $Camera2D
@onready var inv := $Inventory

func _ready() -> void:
	var room_rect: Rect2i = Rect2i(Vector2i(0, 0), get_viewport().get_visible_rect().size)
	$Camera2D.global_position = room_rect.position + room_rect.size / 2

func _process(delta: float) -> void:
	if Input.is_key_label_pressed(KEY_ESCAPE):
		get_tree().quit()
	camera.position = $Player.global_position
	inv.position = camera.position - get_viewport().get_visible_rect().size/2
