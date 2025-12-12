extends Node2D

const TILESIZE = Global.TILESIZE
@onready var enemy_scene_torch = preload("res://Scenes/enemy_torch.tscn")
@export var spawn_rect: Rect2 = Rect2(Vector2(-400, -300), Vector2(800, 600))
var spawn_amount = 5
var ids = 0
var lvl
@onready var player = $"../Player"
@onready var world = $"../WorldGenerator"
@onready var item_generator = $"../WorldGenerator/ItemLoader"
var enemies = []
#var items = []

func _ready() -> void:
	pass
	#world.spawn()
	
var rng := RandomNumberGenerator.new()

func set_seed(s: int):
	rng.seed = s
	
	
func set_lvl(l):
	lvl = l

func spawn_enemies() -> void:
	for i in spawn_amount:
		var enemy = enemy_scene_torch.instantiate()
		enemy.sizer = get_viewport().get_visible_rect().size
		enemy.init(Vector2i(0, 0), i)
		enemies.append(enemy)
		#enemy.player = player= $"../Player"
		enemy.player = player
		enemy.world = world
		
		add_child(enemy)
		


func give_number_of_enemies(complexity, mn, mx):
	var number_of_enemies
	var avg = lerp(4.0, 7.0, complexity)
	var random_offset = rng.randf_range(-1.5, 2.5)
	number_of_enemies = int(round(avg + random_offset))
	number_of_enemies = clamp(number_of_enemies, mn, mx)
	return number_of_enemies
	
	
func give_grid_for_lvl(x, y, w, h, dimw, dimh):
	var grid = []
	for i in [x, x + floor(w / dimw), x + floor(w / dimw) + floor(w / dimw)]:
		for j in [y, y + floor(h / dimh), y + floor(h / dimh) + floor(h / dimh)]:
			var r = floor(w / dimw)
			var t = floor(h / dimh)
			grid.append(Rect2i(Vector2i(i, j), Vector2i(r, t)))
	return grid
	

func spawn_enemies_room(x, y, w, h, complexity, hills, walkable_hills):
	#var items = item_generator.get_items(player.lvls_passed)
	
	#print(items)
	var number_of_enemies = give_number_of_enemies(complexity, 3, 9)
	var items = item_generator.get_items(number_of_enemies)
	#number_of_enemies = 2
	var grid = give_grid_for_lvl(x, y, w, h, 3, 3)
	for i in number_of_enemies:
		var enemy = enemy_scene_torch.instantiate()
		var grid_palce = rng.randi_range(0, len(grid) - 1)
		var grid_coords = grid[grid_palce]
		var position_grid = Vector2i(rng.randi_range(grid_coords.position.x, grid_coords.position.x + grid_coords.size.x), rng.randi_range(grid_coords.position.y, grid_coords.position.y + grid_coords.size.y))
		var increment = randi_range(60 * (player.levelsCompleted - 1), 70 * (player.levelsCompleted - 1))
		var health = lerp(rng.randi_range(100 + increment, 200 + increment), rng.randi_range(250 + increment, 300 + increment), complexity)
		grid.pop_at(grid_palce)
		enemy.init(position_grid * TILESIZE, ids, health)
		enemy.player = player
		enemy.world = world
		ids += 1
		enemies.append(enemy)
		enemy.enemy_died.connect(delete_enemy)
		add_child(enemy)
		if items:
			var item_scene = items[rng.randi_range(0, len(items) - 1)]
			items.pop_at(items.find(item_scene))
			var it = item_scene.instantiate()

			# Set a proper name for inventory pickup
			var path_split = item_scene.resource_path.split("/")  # ["res:", "Items", "Sword", "Sword_item.tscn"]
			var folder_name = path_split[path_split.size() - 2]  # "Sword"
			it.name = folder_name.to_lower() + "_item" + str(i)
			print(it.name)

			it.global_position = position_grid * TILESIZE
			it.scale = Vector2(3, 3)
			it.z_index = 4
			player.connect_ground_item(it)
			add_child(it)

		
		#if items:
			#var item = items[rng.randi_range(0, len(items) - 1)]
			#items.pop_at(items.find(item))
			##print(item)
			#i = item.instantiate()
			#i.global_position = position_grid * TILESIZE
			#i.scale = Vector2(3, 3)
			#i.z_index = 4
			#player.connect_ground_item(i)
			##item.instantiate()
			
			#add_child(i)
			
	#print(len(enemies))


func delete_enemy(enemy):
	enemies.pop_at(enemies.find(enemy))
	#print(len(enemies))
		
#func give_player_world(p, w):
	#for enemy in enemies:
		#enemy.player = p
		#enemy.world = w
