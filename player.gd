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
@export var inventory: Dictionary[Vector2i, String]
@export var inventorySize: int
const inventoryWidth = 9
const inventoryHeight = 4

@export var HPmax: int = 3
@export var currentHP: int = HPmax
@export var attackSpeed: int = 1
@export var projectileNum: int = 0

var enemies_following: Array[CharacterBody2D]

signal open_inventory
signal close_inventory
var inventoryOpened: bool

var highlightCol = Color(255,255,255,0)


func _on_enter_tree():
	Global.player = self
	
func _ready() -> void:
	Global.player = self
	updateHighlightColour()


func updateHighlightColour():
	var config = ConfigFile.new()
	var err = config.load("res://SaveData/settings.config")

	if err != OK:
		return

	highlightCol = config.get_value("Highlight", "player", highlightCol)
	$Highlight.color = highlightCol


func _physics_process(delta: float) -> void:
	#print(attackSpeed)
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play()
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
		print(self.position.distance_to(ray.get_collision_point()))
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
	
		
func _on_ground_item_body_entered(body:Node2D, emitter:Node2D) -> void:
	if inventorySize < inventoryWidth * inventoryHeight:
		var emitterName = emitter.name.split("_")[0].to_lower()
		print(emitterName)
		#var item = load("res://Items/%s/%s.tscn" % [emitterName,emitterName]).instantiate()
		inventory[Vector2i(inventorySize % inventoryWidth, inventorySize / inventoryWidth)] = emitterName
		inventorySize += 1
		print(inventory)
		emitter.call_deferred("queue_free")



func removeItemFromInventory(inv:Dictionary) -> void:
	inventory = inv
