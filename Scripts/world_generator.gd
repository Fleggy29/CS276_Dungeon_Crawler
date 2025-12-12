class_name  World
extends Node2D

@export var noise_height_text : NoiseTexture2D
@export var rock_noise_value = 0.1
@onready var foam_layer = $Foam
@onready var ground_layer_0 = $Ground0
@onready var rocks_layer_1 = $Rocks1
@onready var ground_layer_1 = $Ground1
@onready var bridges_layer = $Bridges
@onready var player = $"../Player"
@onready var enemies_generator = $"../EnemiesGenerator"
var player_position_on_floor = true
var passing_ladder = false
var noise : Noise

const W = 32
const MARGIN_W = 4
const H = 18
const MARGIN_H = 2
const HILL_MIN := 8  
const HILL_MAX := 60 
const MIN_DEGREE := 2
const DIRS := [Vector2i(0, 1), Vector2i(-1,0), Vector2i(0, -1), Vector2i(1, 0)]
@export var terrain_set := 0
@export var T_GROUND := 0
@export var T_HILL   := 1

var source_id = 2
var grass_tile = Vector2i(1,1)
var land_tile = Vector2i(6,1)
var lvl
var spawn_enemies_room_data = []
var boat_pos = Vector2i.ZERO

@export var generate_on_ready = false

var rng = RandomNumberGenerator.new()

func set_seed(s: int):
	rng.seed = s
	noise = noise_height_text.noise
	noise.seed = s
	generateWorld()


func generateWorld():
	player.global_position += Vector2(200, 200)
	var lvl_data = generate_level(rng.randi_range(1, 3))
	lvl = lvl_data[0]
	var bridges = lvl_data[1]
	for i in range(len(lvl)):
		generate_room(lvl[i].x * W, lvl[i].y * H, bridges[i], i)
		
func _process(delta: float) -> void:
	get_player_terrain()

func generate_items(difficulty: int) -> Array:
	return []
	
	
func generate_level(c):
	var k = [[], [], [], []]
	var res = [Vector2i(0, 0)]
	c = 4
	var next = Vector2i(0, 0)
	for j in range(3):
		var r = rng.randi_range(0, 3)
		while r in k[j]:
			r = rng.randi_range(0, 3)
		k[j].append(r)
		var mod = DIRS[r]
		var cur = next
		next = next + mod
		res.insert(j + 1, next)
		k[j + 1].append((r + 2) % 4)
		var t = rng.randi_range(0, 3 + j)
		if t >= 2:
			var coef = rng.randi_range(0, 3)
			while coef in k[j]:
				coef = rng.randi_range(0, 3)
			k[j].append(coef)
			k.append([])
			k[c].append((coef + 2) % 4)
			mod = DIRS[coef]
			res.append(cur + mod)
			c += 1
	return [res, k]
		

func generate_room(coords_x, coords_y, bridges, lvl_number):
	#print(9)
	var threshold := 0.05
	var kept_comps: Array = []
	for _attempt in range(24):
		var hills_set := {}
		var ground := []
		for y in range(coords_y + MARGIN_H, coords_y + H - MARGIN_H):
			for x in range(coords_x + MARGIN_W, coords_x + W - MARGIN_W):
				var h := noise.get_noise_2d(x, y)
				var p := Vector2i(x, y)
				if h > threshold and (coords_y + MARGIN_H) < y  and y < (coords_y + H - MARGIN_H - 2) and (coords_x + MARGIN_W) < x  and x < (coords_x + W - MARGIN_W - 1):
					hills_set[p] = true
				else:
					ground.append(p)
		hills_set = _prune_low_degree(hills_set, coords_x, coords_y)
		var comps := _components(hills_set, coords_x, coords_y)
		kept_comps = []
		for comp in comps:
			if comp.size() < HILL_MIN:
				continue
			if comp.size() > HILL_MAX:
				comp = _shrink_component(comp, HILL_MAX, coords_x, coords_y)
				if comp.size() < HILL_MIN:
					continue
			comp = extend_singles(comp, coords_x, coords_y)
			kept_comps.append(comp)
		var n := kept_comps.size()
		if n >= 2 and n <= 4:
			_paint(kept_comps, coords_x, coords_y, bridges, lvl_number)
			return
		if n > 4: threshold += 0.03
		else:     threshold -= 0.03
	_paint(kept_comps, coords_x, coords_y, bridges, lvl_number)

	
func _paint(components: Array, coords_x, coords_y, bridges, lvl_number):
	var hill_cells: Array[Vector2i] = []
	var hill_grass_cells: Array[Vector2i] = []
	var stairs_cells: Array[Vector2i] = []
	var ground_cells: Array[Vector2i] = []
	var border_rocks_cell: Array
	var all_hills := {}  # set for quick lookup
	var counter = 0
	for comp in components:
		border_rocks_cell.append([])
		for p in comp:
			all_hills[p] = true
			hill_cells.append(p)
			if p + Vector2i(0, 1) in comp:
				hill_grass_cells.append(p)
			else:
				if p + Vector2i(1, 1) not in comp and p + Vector2i(-1, 1) not in comp:
					border_rocks_cell[counter].append(p)
		var l = len(border_rocks_cell[counter])
		var st = border_rocks_cell[counter][rng.randi_range(0, l-1)] + Vector2i(0, 1)
		hill_grass_cells.append(st - Vector2i(0, 1))
		hill_cells.append(st)
		counter += 1
		

	for y in range(coords_y + MARGIN_H, coords_y + H - MARGIN_H):
		for x in range(coords_x + MARGIN_W, coords_x + W - MARGIN_W):
			if x == coords_x + MARGIN_W or x == coords_x + W - MARGIN_W - 1 or y == coords_y + MARGIN_H or y == coords_y + H - MARGIN_H - 1:
				foam_layer.set_cell(Vector2i(x, y), 2, Vector2i.ZERO, 1)
			var p := Vector2i(x, y)
			ground_cells.append(p)
	var bridges_cells = []
	for i in bridges:
		var st1 = Vector2i.ZERO
		var st2 = Vector2i.ZERO
		var m = 0
		var dir = DIRS[i]
		if i == 0:
			st1 = Vector2i((coords_x + floori(W / 2)) / 2, (coords_y + H - MARGIN_H) / 2 - 1)
			m = MARGIN_H
		elif i == 2:
			st1 = Vector2i((coords_x + floori(W / 2)) / 2, (coords_y + MARGIN_H) / 2)
			m = MARGIN_H
		elif i == 1:
			st1 = Vector2i((coords_x + MARGIN_W) / 2, (coords_y + floori(H / 2)) / 2)
			m = MARGIN_W
		elif i == 3:
			st1 = Vector2i((coords_x + W - MARGIN_W) / 2 - 1, (coords_y + floori(H / 2)) / 2)
			m = MARGIN_W
		bridges_cells.append(st1)
		for j in range(m):
			st1 = st1 + dir
			bridges_cells.append(st1)
	for i in hill_cells:
		ground_cells.remove_at(ground_cells.find(i))
	ground_layer_0.set_cells_terrain_connect(ground_cells, terrain_set, T_GROUND)
	bridges_layer.set_cells_terrain_connect(bridges_cells, terrain_set, 0)
	rocks_layer_1.set_cells_terrain_connect(hill_cells, terrain_set, 0)
	ground_layer_1.set_cells_terrain_connect(hill_grass_cells, terrain_set, 1)
	spawn_enemies_room_data.append([coords_x + MARGIN_W, coords_y + MARGIN_H, W - MARGIN_W * 2, H - MARGIN_H * 2, float(lvl_number) / float(len(lvl) - 1), hill_cells, hill_grass_cells])
	if lvl_number == len(lvl) - 1:
		var cur = lvl[lvl_number]
		var t = Vector2i.ZERO
		#print(lvl)
		if cur + Vector2i(0, -1) not in lvl:
			t = ground_cells[12] + Vector2i(0, -1)
		elif cur + Vector2i(0, 1) not in lvl:
			t = ground_cells[-12] + Vector2i(0, 1)
		elif cur + Vector2i(-1, 0) not in lvl:
			t = ground_cells[len(ground_cells) / 2 - 7] + Vector2i(-1, 0)
		elif cur + Vector2i(1, 0) not in lvl:
			t = ground_cells[len(ground_cells) / 2 + 7] + Vector2i(1, 0)
		boat_pos = ground_layer_0.map_to_local(t)
		foam_layer.set_cell(t, 2, Vector2i.ZERO, 1)
	#print(spawn_enemies_room_data, 13)
	
func spawn():
	#print(10)
	for i in spawn_enemies_room_data:
		#print(11)
		#print(i[0], "a", i[1], "a", i[2], "a", i[3])
		enemies_generator.spawn_enemies_room(i[0], i[1], i[2], i[3], i[4], i[5], i[6])
	
func _components(s: Dictionary, start_x, start_y) -> Array:
	var rect := Rect2i(Vector2i(start_x, start_y), Vector2i(W, H))
	var seen := {}
	var out: Array = []
	for p in s.keys():
		if seen.has(p): continue
		var comp: Array[Vector2i] = []
		var q: Array[Vector2i] = [p]
		seen[p] = true
		while q.size() > 0:
			var c = q.pop_back()
			comp.append(c)
			for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
				var n = c + d
				if not rect.has_point(n): continue
				if seen.has(n): continue
				if not s.has(n): continue
				seen[n] = true
				q.append(n)
		out.append(comp)
	return out
	

func _shrink_component(comp: Array[Vector2i], max_keep: int, start_x, start_y) -> Array[Vector2i]:
	if comp.size() <= max_keep:
		return comp
	var s := {}
	for p in comp: s[p] = true
	var rect := Rect2i(Vector2i(start_x, start_y), Vector2i(W, H))
	while comp.size() > max_keep:
		var perimeter: Array[Vector2i] = []
		for p in comp:
			if _is_perimeter(p, s, rect):
				perimeter.append(p)
		if perimeter.is_empty():
			break
		for p in perimeter:
			s.erase(p)
		comp = []
		for key in s.keys(): comp.append(key)
		var parts := _components(s, start_x, start_y)
		if parts.size() > 1:
			var largest = parts[0]
			for arr in parts:
				if arr.size() > largest.size():
					largest = arr
			s.clear()
			for p in largest: s[p] = true
			comp = largest
	return comp
	
	
func extend_singles(comp, start_x, start_y):
	var rect := Rect2i(Vector2i(start_x, start_y), Vector2i(W, H))
	var res_comp = []
	for i in comp:
		var top = i + Vector2i(0, 1)
		var bottom = i + Vector2i(0, -1) 
		if top in comp or bottom in comp:
			res_comp.append(i)
			continue
		if rect.has_point(bottom):
			res_comp.append(i)
			res_comp.append(bottom)
		elif rect.has_point(top):
			res_comp.append(i)
			res_comp.append(top)
	return res_comp
	
	
func _prune_low_degree(hill_set: Dictionary, start_x, start_y) -> Dictionary:
		var rect = Rect2i(Vector2i(start_x, start_y), Vector2i(W, H))
		var changed := true
		while changed:
			changed = false
			var to_remove: Array[Vector2i] = []
			for p in hill_set.keys():
				var deg := 0
				for d in DIRS:
					var n = p + d
					if rect.has_point(n) and hill_set.has(n):
						deg += 1
				if deg < MIN_DEGREE:
					to_remove.append(p)
			if to_remove.size() > 0:
				changed = true
				for p in to_remove:
					hill_set.erase(p)
		return hill_set


func _is_perimeter(p: Vector2i, s: Dictionary, rect: Rect2i) -> bool:
	for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var n = p + d
		if not rect.has_point(n): return true
		if not s.has(n): return true
	return false
	
	
func get_player_terrain():
	var tile_pos = rocks_layer_1.local_to_map(player.global_position)
	var tile_data = rocks_layer_1.get_cell_tile_data(tile_pos)
	if tile_data == null:
		if passing_ladder == true and player_position_on_floor == false:
			player.collision_mask = 1
			player_position_on_floor = true
		player.z_index = 0
		passing_ladder = false
		return -1
	var coords = rocks_layer_1.get_cell_atlas_coords(tile_pos)
	if coords == Vector2i(3, 7):
		passing_ladder = true
		player.z_index = 3
	else:
		if passing_ladder == true and player_position_on_floor == true:
			player.collision_mask = 2
			player_position_on_floor = false
			
		passing_ladder = false
		return -1
	return 1
	
func get_terrain(pos, local=true):
	var tile_pos_ground
	var tile_pos_rock
	var tile_pos_rock_walk
	if local:
		tile_pos_ground = ground_layer_0.local_to_map(pos)
		tile_pos_rock = rocks_layer_1.local_to_map(pos)
		tile_pos_rock_walk = ground_layer_1.local_to_map(pos)
	else:
		tile_pos_ground = pos
		tile_pos_rock = pos
	var tile_data_ground = ground_layer_0.get_cell_tile_data(tile_pos_ground)
	var tile_data_rock_walk = ground_layer_1.get_cell_tile_data(tile_pos_rock_walk)
	var tile_data_rock = rocks_layer_1.get_cell_tile_data(tile_pos_rock)
	return {"ground": tile_data_ground, "rock": tile_data_rock, "walkable_rock": tile_data_rock}


func get_map_position(pos):
	return ground_layer_0.local_to_map(player.global_position)
	
	
	
	
