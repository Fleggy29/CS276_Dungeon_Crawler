extends Node2D

@export var noise_height_text : NoiseTexture2D
@export var rock_noise_value = 0.1
@onready var foam_layer = $Foam
@onready var ground_layer_0 = $Ground0
@onready var rocks_layer_1 = $Rocks1
@onready var ground_layer_1 = $Ground1
@onready var rocks_layer_2 = $Rocks2
@onready var ground_layer_2 = $Ground2
@onready var bridges_layer = $Bridges
var noise : Noise

const W = 32
const MARGIN_W = 4
const H = 18
const MARGIN_H = 2
const HILL_MIN := 8  
const HILL_MAX := 40 
const MIN_DEGREE := 2
const DIRS := [Vector2i(0, 1), Vector2i(-1,0), Vector2i(0, -1), Vector2i(1, 0)]
@export var terrain_set := 0
@export var T_GROUND := 0
@export var T_HILL   := 1

var source_id = 2
var grass_tile = Vector2i(1,1)
var land_tile = Vector2i(6,1)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise = noise_height_text.noise
	#var start_x = 0
	#var start_y = 0
	var lvl_data = generate_level(randi_range(1, 3))
	var lvl = lvl_data[0]
	var bridges = lvl_data[1]
	for i in range(len(lvl)):
		var k = lvl[i]
		generate_room(k.x * W, k.y * H, bridges[i])
		#start_y += H


func generate_level(c):
	var k = [[], [], [], []]
	#var bridges = [[], [], [], []]
	var res = [Vector2i(0, 0)]
	c = 4
	var next = Vector2i(0, 0)
	for j in range(3):
		var r = randi_range(0, 3)
		while r in k[j]:
			r = randi_range(0, 3)
		k[j].append(r)
		var mod = DIRS[r]
		#print(next)
		var cur = next
		next = next + mod
		#print(next)
		#print()
		res.insert(j + 1, next)
		#res.append(next)
		k[j + 1].append((r + 2) % 4)
		var t = randi_range(0, 3 + j)
		if t >= 2:
			var coef = randi_range(0, 3)
			while coef in k[j]:
				coef = randi_range(0, 3)
			k[j].append(coef)
			k.append([])
			k[c].append((coef + 2) % 4)
			mod = DIRS[coef]
			res.append(cur + mod)
			c += 1
	print(k)
	return [res, k]
		

func generate_room(coords_x, coords_y, bridges):
	var threshold := 0.05
	var kept_comps: Array = []
	for _attempt in range(24):
		var hills_set := {}
		var ground := []
		for y in range(coords_y + MARGIN_H, coords_y + H - MARGIN_H):
			for x in range(coords_x + MARGIN_W, coords_x + W - MARGIN_W):
				var h := noise.get_noise_2d(x, y)
				#print(x, y, h)
				var p := Vector2i(x, y)
				if h > threshold and (coords_y + MARGIN_H) < y  and y < (coords_y + H - MARGIN_H - 1) and (coords_x + MARGIN_W) < x  and x < (coords_x + W - MARGIN_W - 1):
					hills_set[p] = true
				else:
					ground.append(p)
					
		hills_set = _prune_low_degree(hills_set, coords_x, coords_y)
		var comps := _components(hills_set, coords_x, coords_y)
		#print(comps)

		kept_comps = []
		for comp in comps:
			if comp.size() < HILL_MIN:
				continue
			if comp.size() > HILL_MAX:
				comp = _shrink_component(comp, HILL_MAX, coords_x, coords_y)
				if comp.size() < HILL_MIN:
					continue
			kept_comps.append(comp)
		var n := kept_comps.size()
		if n >= 2 and n <= 4:
			_paint(kept_comps, coords_x, coords_y, bridges)
			#print(kept_comps)
			return
			#continue
		if n > 4: threshold += 0.03
		else:     threshold -= 0.03
	_paint(kept_comps, coords_x, coords_y, bridges)
#	Second level

	
func _paint(components: Array, coords_x, coords_y, bridges):
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
				border_rocks_cell[counter].append(p)
		var l = len(border_rocks_cell[counter])
		var stairs_amount = min(randi_range(1, 3), l)
		for i in range(stairs_amount):
			stairs_cells.append(border_rocks_cell[counter][randi_range(0, l - 1)])
		#print(stairs_amount)
		counter += 1
	#print(stairs_cells)
	#print(hill_cells)
	#print()
			
			
		

	for y in range(coords_y + MARGIN_H, coords_y + H - MARGIN_H):
		for x in range(coords_x + MARGIN_W, coords_x + W - MARGIN_W):
			if x == coords_x + MARGIN_W or x == coords_x + W - MARGIN_W - 1 or y == coords_y + MARGIN_H or y == coords_y + H - MARGIN_H - 1:
				foam_layer.set_cell(Vector2i(x, y), 2, Vector2i.ZERO, 1)
			var p := Vector2i(x, y)
			ground_cells.append(p)
			#if p in all_hills:
				#if p + Vector2i(0, 1) in all_hills:
					#hill_grass_cells.append(p)
	var bridges_cells = []
	for i in bridges:
		var st1 = Vector2i.ZERO
		var st2 = Vector2i.ZERO
		var m = 0
		var dir = DIRS[i]
		if i == 0:
			st1 = Vector2i((coords_x + floori(W / 2)) / 2, (coords_y + H - MARGIN_H) / 2 - 1)
			#st2 = Vector2i(coords_x + floori(W / 2) + 1, coords_y + H - MARGIN_H)
			m = MARGIN_H
		elif i == 2:
			st1 = Vector2i((coords_x + floori(W / 2)) / 2, (coords_y + MARGIN_H) / 2)
			#st2 = Vector2i(coords_x + floori(W / 2) + 1, MARGIN_H)
			m = MARGIN_H
		elif i == 1:
			st1 = Vector2i((coords_x + MARGIN_W) / 2, (coords_y + floori(H / 2)) / 2)
			#st2 = Vector2i(MARGIN_W, coords_y + floori(H / 2) + 1)
			m = MARGIN_W
		elif i == 3:
			st1 = Vector2i((coords_x + W - MARGIN_W) / 2 - 1, (coords_y + floori(H / 2)) / 2)
			#st2 = Vector2i(coords_x + W - MARGIN_W, coords_y + floori(H / 2) + 1)
			m = MARGIN_W
		bridges_cells.append(st1)
		#bridges_cells.append(st2)
		for j in range(m):
			st1 = st1 + dir
			#st2 = st2 + dir
			bridges_cells.append(st1)
			#bridges_cells.append(st2)
		

	
	ground_layer_0.set_cells_terrain_connect(ground_cells, terrain_set, T_GROUND)
	print(bridges_cells)
	bridges_layer.set_cells_terrain_connect(bridges_cells, terrain_set, 0)
	rocks_layer_1.set_cells_terrain_connect(hill_cells, terrain_set, 0)
	ground_layer_1.set_cells_terrain_connect(hill_grass_cells, terrain_set, 1)
	#ground_layer_1.set_cells_terrain_connect(revs(hill_grass_cells), terrain_set, 1)
	rocks_layer_2.set_cells_terrain_connect(stairs_cells, terrain_set, 2)
	#update_bitmask_region(Rect2i(Vector2i.ZERO, Vector2i(W, H)))
	#print(stairs_cells)
	#print(hill_cells)
	#print()
	#print()
	
func revs(a):
	var res = []
	for i in range(len(a) - 1, 0):
		res.append(i)
	return res
	
#func padded(a: Array[Vector2i]) -> PackedVector2Array:
	#var out: PackedVector2Array
	#var dirs = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	#var seen := {}
	#for c in a:
		#if not seen.has(c):
			#out.append(c); seen[c]=true
		#for d in dirs:
			#var n = c + d
			#if not seen.has(n):
				#out.append(n); seen[n]=true
	#return out
	
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
	
	
# Iterative perimeter erosion until the component size <= max_keep.
# Keeps the interior, which preserves connectivity in practice.
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
	
	
#func generate():
	#var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	#var width : int = int(viewport_size.x / 64)
	#var height : int = int(viewport_size.y / 64)
	#var grass = []
	#var rocks_1 = []
	#var rocks_2 = []
	#for x in range(3, width - 3):
		#for y in range(2, height - 2):
			#if x == 3 or x == width - 4 or y == 2 or y == height - 3:
				#foam_layer.set_cell(Vector2i(x, y), 2, Vector2i.ZERO, 1)
			#var noise_val : float = noise.get_noise_2d(x, y)
			##if noise_val > rock_noise_value + 0.2:
				##rocks_1.append(Vector2i(x,y))
				##rocks_2.append(Vector2i(x,y))
			#if noise_val > rock_noise_value:
				#rocks_1.append(Vector2i(x,y))
			#grass.append(Vector2i(x,y))
			##tile_layer.set_cell(Vector2i(x,y), )
	##tile_layer.set_cells_terrain_connect(grass, 0, 0)
	#ground_layer_0.set_cells_terrain_connect(grass, 0, 0)
	#rocks_layer_1.set_cells_terrain_connect(rocks_1, 0, 0)
	#rocks_layer_1.set_cells_terrain_connect(rocks_2, 0, 0)
