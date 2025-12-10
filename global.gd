class_name Global extends Node

static var player = null
const TILESIZE = 64
@onready var camera := $Camera2D
@onready var inv := $Inventory
@onready var world = $WorldGenerator

var config = ConfigFile.new()

func _ready() -> void:
	var room_rect: Rect2i = Rect2i(Vector2i(0, 0), get_viewport().get_visible_rect().size)
	$Camera2D.global_position = room_rect.position + room_rect.size / 2
	#print(player,0)
	#world.enemies_generator.give_player_world($Player, world)

func _process(delta: float) -> void:
	if Input.is_key_label_pressed(KEY_ESCAPE):
		var packedScene = PackedScene.new()
		config.set_value("SaveState", "scene", packedScene.pack(self))
		config.save("res://SaveData/settings.config")
		get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
		#get_tree().quit()
	else:
		camera.position = $Player.global_position
		inv.position = camera.position - get_viewport().get_visible_rect().size/2
