class_name Player extends CharacterBody2D

const TILESIZE = Global.TILESIZE
const MOVESPEED = 0.25
var speed = 400
var tween: Tween
#var lastDir: RayCast2D
var lastDir: Vector2
@export var weapon: Area2D
@export var items: Array[item_buff]
signal swing_weapon
signal picked_weapon
@export var inventory: Dictionary
@export var inventorySize: int
const inventoryWidth = 9
const inventoryHeight = 4

@export var HPmax: int = 300
@export var currentHP: int = HPmax
@export var MNmax: int = 100
@export var currentMN: int = MNmax
@export var attackSpeed: int = 1
@export var projectileNum: int = 0

signal health_changed
signal mana_changed

var levelsCompleted: int
var enemiesKilled: int
var itemsPickedUp: int

signal dead

var enemies_following: Array[CharacterBody2D]
var bonuses = {"cool_down_bonus": 1}
signal bonuses_updated

signal open_inventory
signal close_inventory
var inventoryOpened: bool

var drawn = false

var highlightCol = Color(255,255,255,0)

var config = ConfigFile.new()

func _on_enter_tree():
	Global.player = self
	
func _ready() -> void:
	Global.player = self
	updateHighlightColour()
	emit_all_stats()

	# Load persistent stats
	levelsCompleted = runState.levelsCompleted
	enemiesKilled = runState.enemiesKilled
	itemsPickedUp = runState.itemsPickedUp

	# Load vitals
	currentHP = runState.currentHP
	HPmax = runState.HPmax

	currentMN = runState.currentMN
	MNmax = runState.MNmax

	# Load inventory
	inventory = runState.inventory
	inventorySize = runState.inventorySize

	emit_all_stats()




func updateHighlightColour():
	var config = ConfigFile.new()
	var err = config.load("res://SaveData/settings.config")

	if err != OK:
		return

	highlightCol = config.get_value("Highlight", "player", highlightCol)
	$Highlight.color = highlightCol

func emit_all_stats():
	health_changed.emit(currentHP, HPmax)
	mana_changed.emit(currentMN, MNmax)

func _physics_process(delta: float) -> void:
	#print(attackSpeed)
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play()
	if drawn:
		$AnimatedSprite2D.animation = "drawn"
	else:
		check_drawn()
		#print(attackSpeed)
		velocity = Vector2.ZERO
		
		if (!tween or !tween.is_running()) and not inventoryOpened:
			if Input.is_action_pressed("move_left") :
			#and not checkCollisionBool($ColliderChecks/ColliderCheckW, 1):
				#lastDir = $ColliderChecks/ColliderCheckW
				lastDir = Vector2.LEFT
				velocity += lastDir
			if Input.is_action_pressed("move_right") :
			#and not checkCollisionBool($ColliderChecks/ColliderCheckE, 1):
				#lastDir = $ColliderChecks/ColliderCheckE
				lastDir = Vector2.RIGHT
				velocity += lastDir
			if Input.is_action_pressed("move_up") :
			#and not checkCollisionBool($ColliderChecks/ColliderCheckN, 1):
				#lastDir = $ColliderChecks/ColliderCheckN
				lastDir = Vector2.UP
				velocity += lastDir
			if Input.is_action_pressed("move_down") :
			#and not checkCollisionBool($ColliderChecks/ColliderCheckS, 1):
				#lastDir = $ColliderChecks/ColliderCheckS
				lastDir = Vector2.DOWN
				velocity += lastDir
			velocity = velocity.normalized()
			if Input.is_action_pressed("dash") :
			#and not checkCollisionBool(lastDir, 2):
				#move(lastDir.target_position.normalized() * 2)
				velocity *= 2
			#elif Input.is_action_pressed("dash") and not checkCollisionBool(lastDir, 1):
				#move(lastDir.target_position.normalized())
			velocity *= speed
			move_and_slide()
		if Input.is_action_pressed("attack") and weapon and not inventoryOpened:
				emit_signal("swing_weapon", attackSpeed, projectileNum)
		if Input.is_action_just_pressed("inventory"):
			if not inventoryOpened:
				emit_signal("open_inventory", inventory)
				inventoryOpened = true
			else:
				emit_signal("close_inventory")
				inventoryOpened = false
		if velocity != Vector2.ZERO:
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.animation = "walk"
		else:
			$AnimatedSprite2D.animation = "idle"


func checkCollisionBool(ray: RayCast2D, distance: int) -> bool:
	if ray.is_colliding():
		#print(self.position.distance_to(ray.get_collision_point()))
		if self.position.distance_to(ray.get_collision_point()) < distance * TILESIZE:
			if ray.get_collider() is TileMapLayer:
				return true
	return false

func move(dir: Vector2):
	if tween:
		tween.kill()
	$AnimatedSprite2D.animation = "walk"
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", position + TILESIZE * dir, MOVESPEED).set_trans(Tween.TRANS_SINE)

func equipWeapon (weaponName: String) -> void:
	emit_signal("close_inventory")
	inventoryOpened = false
	if weapon:
		weapon.call_deferred("queue_free")
	weapon = load("res://Items/%s/%s.tscn" % [weaponName,weaponName]).instantiate()
	#print(weapon)
	#print(weapon.name)
	var pivot = Node2D.new()
	pivot.name = "Weapon_Pivot"
	weapon.position = Vector2(8,0)
	weapon.rotation = PI/2
	add_child(pivot)
	pivot.call_deferred("add_child", weapon)
	
func getName(obj: Object):
	return obj.name

func equipItem (itemName: String) -> void:
	emit_signal("close_inventory")
	inventoryOpened = false
	for item in items:
		#print(item)
		if item.name == itemName:
			item.call_deferred("remove")
			items.erase(item)
	if items.size() < 3:
		var i = load("res://Items/%s/%s.tscn" % [itemName,itemName]).instantiate()

		
		
		#print("name:", i.name)
		add_child(i)
		items.append(i)
		#print(items)
		#print("item:", i)
		i.add()
		#print(attackSpeed)
	
		
#func _on_ground_item_body_entered(body:Node2D, emitter:Node2D) -> void:
	#itemsPickedUp += 1
	#runState.itemsPickedUp = itemsPickedUp
#
	#if inventorySize < inventoryWidth * inventoryHeight:
		##print(10)
		#var emitterName = emitter.name.split("_")[0].to_lower()
		#if emitterName == "atkspd":
			#bonuses["cool_down_bonus"] = 0.7
			#bonuses_updated.emit()
		##var item = load("res://Items/%s/%s.tscn" % [emitterName,emitterName]).instantiate()
		#inventory[Vector2i(inventorySize % inventoryWidth, inventorySize / inventoryWidth)] = emitterName
		#inventorySize += 1
		##print(inventory)
		#runState.inventory = inventory
		#runState.inventorySize = inventorySize
		#add_mana(randi_range(5, 12))
#
		#emitter.call_deferred("queue_free")
		
func _on_ground_item_body_entered(body: Node2D, emitter: Node2D) -> void:
	itemsPickedUp += 1
	runState.itemsPickedUp = itemsPickedUp

	if inventorySize < inventoryWidth * inventoryHeight:
		# Ensure the emitter has a proper name
		var emitterName = str(emitter.name).split("_")[0].to_lower()
		if emitterName == "":
			emitterName = "unknown_item"
		
		if emitterName == "atkspd":
			bonuses["cool_down_bonus"] = 0.7
			bonuses_updated.emit()

		print("picked up: ", emitterName)

		# Store the level along with the item name in the inventory
		var item_data = {
			"name": emitterName,
			"lvl": levelsCompleted  # store the level at pickup
		}
		inventory[Vector2i(inventorySize % inventoryWidth, inventorySize / inventoryWidth)] = item_data
		inventorySize += 1
		#print(inventory)
		runState.inventory = inventory
		runState.inventorySize = inventorySize
		add_mana(randi_range(5, 12))

		emitter.call_deferred("queue_free")



		
func connect_ground_item(item):
	item.ground_item_body_entered.connect(_on_ground_item_body_entered)

func take_damage(dmg):
	#print("took danage")sdadsdas
	if currentHP >= dmg:
		currentHP -= dmg
		runState.currentHP = currentHP
		health_changed.emit(currentHP, HPmax)
		flash_red()
		return true

	currentHP = 0
	runState.currentHP = currentHP
	health_changed.emit(currentHP, HPmax)
	config.set_value("SaveState", "showResume", true)
	runState.levelsCompleted = 0
	runState.enemiesKilled = 0
	runState.itemsPickedUp = 0
	runState.inventory = {}
	runState.inventorySize = 0

	config.save("res://SaveData/settings.config")
	Global.shouldGenerate = true
	emit_signal("dead", levelsCompleted, enemiesKilled, itemsPickedUp)
	#inventoryOpened = true
	return false

	
	
func flash_red():
	var sprite = $AnimatedSprite2D
	sprite.modulate = Color.WHITE
	var t = get_tree().create_tween()
	t.set_trans(Tween.TRANS_LINEAR)
	t.set_ease(Tween.EASE_IN_OUT)
	t.tween_property(sprite, "modulate", Color(1, 0, 0), 0.05)
	t.tween_property(sprite, "modulate", Color(1, 1, 1), 0.15)
	
func use_mana(mana):
	#print(currentMN)
	if currentMN >= mana:
		currentMN -= mana
		runState.currentMN = currentMN
		mana_changed.emit(currentMN, MNmax)
		return true
	#currentMN = 0
	mana_changed.emit(currentMN, MNmax)
	return false

func add_mana(mana):
	currentMN = min(currentMN + mana, MNmax)
	runState.currentMN = currentMN
	mana_changed.emit(currentMN, MNmax)
	return true



func removeItemFromInventory(inv:Dictionary) -> void:
	inventory = inv
	runState.inventory = inv
	runState.inventorySize = inv.size()
	
func check_drawn():
	
	var under = $"../WorldGenerator".get_terrain(position, true)
	#print(under)
	if !under["ground"] and !under["rock"] and !under["walkable_rock"] and !under["foam"] and !under["bridges"]:
		$AnimatedSprite2D.animation = "drawn"
		drawn = true
		z_index = 0
		$"../WorldGenerator".z_index = 3
		print(under)
		await $AnimatedSprite2D.animation_finished
		take_damage(currentHP)
	


#func _on_bow_item_ground_item_body_entered(body: Node2D, emitter: Node2D) -> void:
	#pass # Replace with function body.
