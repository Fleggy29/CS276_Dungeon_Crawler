class_name Global extends Node

static var seed: int = 0
static var player = null
const TILESIZE = 64
@onready var camera := $Camera2D
@onready var inv := $Inventory
@onready var worldGen := $WorldGenerator
@onready var itemLoader := $WorldGenerator/ItemLoader
@onready var enemyGen := $EnemiesGenerator

static var shouldGenerate = true

var config = ConfigFile.new()

func _ready() -> void:
	player = $Player
	camera.position = player.global_position
	print("seed: ", seed)
	if shouldGenerate:
		if Global.seed == 0:      # not set? randomize once
			var r := RandomNumberGenerator.new()
			r.randomize()
			Global.seed = r.randi()
	else:
		load_game()
	print("seed: ", seed)
	# Send the seed to all systems:
	worldGen.set_seed(Global.seed)
	itemLoader.set_seed(Global.seed)
	enemyGen.set_seed(Global.seed)
	#worldGen.generate_world()
	worldGen.spawn()
	
	inv.position = camera.position - get_viewport().get_visible_rect().size / 2


func _process(delta: float) -> void:
	if Input.is_key_label_pressed(KEY_ESCAPE):
		get_tree().paused = false
		save_game()
		get_tree().change_scene_to_file("res://Menu/main_menu.tscn")
		#get_tree().quit()
	else:
		camera.position = $Player.global_position
		inv.position = camera.position - get_viewport().get_visible_rect().size/2
		$DeathScreen.position = camera.position - get_viewport().get_visible_rect().size/2


func save_game() -> void:
	var player_props := {}
	var prop_names := []
	for p in player.get_property_list():
		prop_names.append(p.name)


	player_props.position = [player.global_position.x, player.global_position.y]

	player_props.velocity = [player.velocity.x, player.velocity.y] if "velocity" in prop_names else null
	player_props.currentHP = player.currentHP if "currentHP" in prop_names else null
	player_props.levelsCompleted = player.levelsCompleted if "levelsCompleted" in prop_names else null
	player_props.enemiesKilled = player.enemiesKilled if "enemiesKilled" in prop_names else null
	player_props.itemsPickedUp = player.itemsPickedUp if "itemsPickedUp" in prop_names else null
	var inv_serialized: Dictionary = {}
	for pos in player.inventory.keys():
		var key_string = str(pos.x) + "," + str(pos.y)
		inv_serialized[key_string] = player.inventory[pos]

	player_props.inventory = inv_serialized


	var save_dict := {
		"seed": Global.seed,
		"player": player_props
	}

	var json_text := JSON.stringify(save_dict)
	config.load("res://SaveData/settings.config")
	config.set_value("SaveState", "data", json_text)
	config.save("res://SaveData/settings.config")

	print("[Save] Game saved with seed =", Global.seed)


func load_game() -> void:
	var err := config.load("res://SaveData/settings.config")
	if err != OK:
		print("[Load] No save file found.")
		return

	var json_text : String = config.get_value("SaveState", "data")
	if json_text == null:
		print("[Load] No save data section found.")
		return

	var parsed = JSON.parse_string(json_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		print("[Load] Invalid save data format.")
		return

	var data: Dictionary = parsed


	if data.has("seed"):
		Global.seed = int(data["seed"])
		print("[Load] Loaded seed =", Global.seed)
	else:
		print("[Load] WARNING: No seed in save!")

	
	var prop_names: Array[String] = []
	for prop in player.get_property_list():
		prop_names.append(prop.name)



	if data.has("player"):
		var p = data["player"]

		if p.has("position") and p["position"] != null:
			var pos = p["position"]
			player.global_position = Vector2(pos[0], pos[1])


		if p.has("velocity") and p["velocity"] != null and "velocity" in prop_names:
			var vel = p["velocity"]
			player.velocity = Vector2(vel[0], vel[1])


		if p.has("currentHP") and "currentHP" in prop_names:
			player.currentHP = p["currentHP"]
		
		if p.has("levelsCompleted") and "levelsCompleted" in prop_names:
			player.levelsCompleted = p["levelsCompleted"]
		
		if p.has("enemiesKilled") and "enemiesKilled" in prop_names:
			player.enemiesKilled = p["enemiesKilled"]
		
		if p.has("itemsPickedUp") and "itemsPickedUp" in prop_names:
			player.itemsPickedUp = p["itemsPickedUp"]

		if "inventory" in p and "inventory" in prop_names:
			var loaded_inventory: Dictionary[Vector2i, String] = {}
			for k_str in p["inventory"].keys():
				var parts = k_str.split(",")
				if parts.size() == 2:
					var vec = Vector2i(parts[0].to_int(), parts[1].to_int())
					loaded_inventory[vec] = str(p["inventory"][k_str])
			player.inventory = loaded_inventory



		print("[Load] Player restored.")

	print("[Load] Game restored successfully.")
