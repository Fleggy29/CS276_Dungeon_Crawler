extends Node2D

const TILESIZE = Global.TILESIZE
@export var inventory: Dictionary
signal playerEquipWeapon
signal playerEquipItem
signal removeItemFromInventory

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("select"):
		if $Cursor.has_overlapping_areas():
			for area in $Cursor.get_overlapping_areas():
				var name = area.name.split("_")[0].to_lower()
				#print("area name:", name)
				if area is GroundItem and ResourceLoader.exists("res://Items/%s/%s_item.tscn" % [name,name]):
					#print("area:", area)
					if area.is_in_group("weapon"):
						var selectedWeapon = area
						#print("check")
						emit_signal("playerEquipWeapon", name)
					else:
						#print("equipping item")
						emit_signal("playerEquipItem", name)
	if Input.is_action_just_pressed("drop"):
		if $Cursor.has_overlapping_areas():
			for area in $Cursor.get_overlapping_areas():
				if area is GroundItem:
					var selectedWeapon = area
					var selectedWeaponName = selectedWeapon.name.split("_")[0].to_lower()
					var keyToDelete = (Vector2i(round($Cursor.position.x), round($Cursor.position.y)) - Vector2i(128,128)) / TILESIZE
					inventory.set(keyToDelete, "")
					inventory = inventory_reorganise(inventory)
					inventory.erase(inventory.keys()[-1])
					emit_signal("removeItemFromInventory", inventory)
					_on_player_close_inventory()
					_on_player_open_inventory(inventory)
		


#func _on_player_open_inventory(inv: Dictionary) -> void:
	#show()
	##print("inventory")
	#inventory = inv
	#var item: Area2D 
	#for key in inv.keys():
		#var itemName = inv[key]
		#item = load("res://Items/%s/%s_item.tscn" % [itemName,itemName]).instantiate()
		#item.position = key * TILESIZE + Vector2i(128, 128)
		#item.scale = Vector2(2,2)
		#item.collision_layer = 2
		#item.collision_mask = 2
		#item.add_to_group("inventory_item")
		#add_child(item)
		
func _on_player_open_inventory(inv: Dictionary) -> void:
	show()
	inventory = inv
	var item: Area2D
	var i = 0
	for key in inv.keys():
		var item_data = inv[key]
		if item_data == null or item_data.size() == 0:
			continue  # skip empty slots

		var itemName = item_data["name"]
		var itemLevel = item_data.get("lvl", 1)  # default level = 1
		if itemName.contains("area"):
			break
		# Instantiate the item
		item = load("res://Items/%s/%s_item.tscn" % [itemName, itemName]).instantiate()
		
		
		# Set level if the item has a 'lvl' property
		if "lvl" in item:
			item.lvl = itemLevel

		# Set item position and appearance
		item.position = key * TILESIZE + Vector2i(128, 128)
		item.scale = Vector2(2, 2)
		item.collision_layer = 2
		item.collision_mask = 2
		item.add_to_group("inventory_item")

		# Add level label for all items
		var lvl_label = Label.new()
		lvl_label.text = str(itemLevel)
		lvl_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lvl_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lvl_label.position = Vector2(5, -10)
		lvl_label.add_theme_color_override("font_color", Color.WHITE)
		lvl_label.add_theme_font_size_override("font_size", 8)
		item.add_child(lvl_label)

		add_child(item)
		i += 1





	


func _on_player_close_inventory() -> void:
	for child in get_children():
		if child is GroundItem:
			#print("deleted", child.name)
			child.queue_free()
			remove_child(child)
			
	hide()
	


func inventory_reorganise(inv: Dictionary) -> Dictionary:
	var moveNextKey: bool
	var previousKey: Vector2i
	for key in inv.keys():
		if moveNextKey:
			inv[previousKey] = inv[key]
			inv[key] = ""
		if inv[key] == "":
			previousKey = key
			moveNextKey = true
	return inv
