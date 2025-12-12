extends Node

# Loads all item definitions once.
var item_defs : Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func set_seed(s: int):
	rng.seed = s
	load_all_items()
	print(get_random_items(5))



func load_all_items():
	var base_dir := "res://Items/"
	var dir := DirAccess.open(base_dir)
	if not dir:
		push_error("Cannot open items directory")
		return

	item_defs.clear()
	
	for folder in dir.get_directories():
		if folder != "Item_Template":
			var folder_path = base_dir + folder + "/"

			# Find the main item scene (the one WITHOUT _item.tscn)
			var sub = DirAccess.open(folder_path)
			if not sub:
				continue

			var scene_path := ""
			var item_scene_path := ""

			for file in sub.get_files():
				if file.ends_with("_item.tscn"):
					item_scene_path = folder_path + file
				elif file.to_lower() == folder.to_lower() + ".tscn":
					scene_path = folder_path + file


			if scene_path == "" or item_scene_path == "":
				continue

			var packed_scene := load(scene_path)
			if packed_scene == null:
				continue

			var inst = packed_scene.instantiate()

			# Expect these vars on the script
			if not inst.has_method("_get_script"):
				pass

			if (not "chance" in inst) or (not "value" in inst):
				push_error("Item scene " + scene_path + " missing 'chance' or 'value'")
				continue

			item_defs.append({
				"chance": inst.chance,
				"value": inst.value,
				"scene": load(item_scene_path)  # this is the version you return
			})
	print("items:", item_defs)

func get_random_items(difficulty: int) -> Array:
	print("SEEEED: ", Global.seed)
	var threshold := difficulty * 10  
	var remainingValue := threshold

	var results := []
	var pool := item_defs.duplicate()


	while true:
		var pickedAny := false

		for item in pool:
			if item["value"] > remainingValue:
				continue  # can't afford this item, skip it

			# Chance is absolute percentage (0–100)
			var roll := rng.randf() * 100.0
			if roll <= item["chance"]:
				# Success: select this item
				results.append(item["scene"])
				remainingValue -= item["value"]
				pickedAny = true

		if not pickedAny:
			break  # nothing rolled successfully; stop
			
	return results
