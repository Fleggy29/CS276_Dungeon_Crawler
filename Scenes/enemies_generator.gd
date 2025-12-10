extends Node2D

const TILESIZE = Global.TILESIZE
@onready var enemy_scene_torch = preload("res://Scenes/enemy_torch.tscn")
@export var spawn_rect: Rect2 = Rect2(Vector2(-400, -300), Vector2(800, 600))
var spawn_amount = 5
var ids = 0
var lvl
@onready var player = $"../Player"
@onready var world = $"../WorldGenerator"
var enemies = []

func _ready() -> void:
	world.spawn()
	

func set_lvl(l):
	lvl = l
	print(lvl)

func spawn_enemies() -> void:
	for i in spawn_amount:
		var enemy = enemy_scene_torch.instantiate()
		enemy.sizer = get_viewport().get_visible_rect().size
		enemy.init(Vector2i(0, 0), i)
		enemies.append(enemy)
		print(player, 0, i)
		#enemy.player = player= $"../Player"
		enemy.player = player
		print(enemy.player, 1, i)
		enemy.world = world
		
		add_child(enemy)
		

func give_number_of_enemies(complexity, mn, mx):
	var number_of_enemies
	var avg = lerp(4.0, 7.0, complexity)
	var random_offset = randf_range(-1.5, 2.5)
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
	var number_of_enemies = give_number_of_enemies(complexity, 3, 9)
	var grid = give_grid_for_lvl(x, y, w, h, 3, 3)
	for i in number_of_enemies:
		var enemy = enemy_scene_torch.instantiate()
		var grid_palce = randi_range(0, len(grid) - 1)
		var grid_coords = grid[grid_palce]
		var position_grid = Vector2i(randi_range(grid_coords.position.x, grid_coords.position.x + grid_coords.size.x), randi_range(grid_coords.position.y, grid_coords.position.y + grid_coords.size.y))
		var health = lerp(randi_range(150, 250), randi_range(350, 450), complexity)
		grid.pop_at(grid_palce)
		enemy.init(position_grid * TILESIZE, ids, health)
		enemy.player = player
		enemy.world = world
		ids += 1
		enemies.append(enemy)
		add_child(enemy)

		
#func give_player_world(p, w):
	#for enemy in enemies:
		#enemy.player = p
		#enemy.world = w
