class_name Player extends CharacterBody2D

const TILESIZE = Global.TILESIZE
const MOVESPEED = 0.25
var tween: Tween
var lastDir: RayCast2D
var weapon: Area2D
signal swing_weapon
signal picked_weapon
var inventory: Dictionary[Vector2i, String]
var inventorySize: int
const inventoryWidth = 9
const inventoryHeight = 4

var HPmax: int = 3
var currentHP: int = HPmax
var attackSpeed: int = 1
var projectileNum: int = 3

signal open_inventory
signal close_inventory
var inventoryOpened: bool


func _on_enter_tree():
	Global.player = self
	
func _ready() -> void:
	Global.player = self
	

func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if !tween or !tween.is_running() and not inventoryOpened:
		if Input.is_action_pressed("move_left") and not checkCollisionBool($ColliderChecks/ColliderCheckW, 1):
			lastDir = $ColliderChecks/ColliderCheckW
			move(Vector2.LEFT)
		if Input.is_action_pressed("move_right") and not checkCollisionBool($ColliderChecks/ColliderCheckE, 1):
			lastDir = $ColliderChecks/ColliderCheckE
			move(Vector2.RIGHT)
		if Input.is_action_pressed("move_up") and not checkCollisionBool($ColliderChecks/ColliderCheckN, 1):
			lastDir = $ColliderChecks/ColliderCheckN
			move(Vector2.UP)
		if Input.is_action_pressed("move_down") and not checkCollisionBool($ColliderChecks/ColliderCheckS, 1):
			lastDir = $ColliderChecks/ColliderCheckS
			move(Vector2.DOWN)
		if Input.is_action_pressed("dash") and not checkCollisionBool(lastDir, 2):
			move(lastDir.target_position.normalized() * 2)
		elif Input.is_action_pressed("dash") and not checkCollisionBool(lastDir, 1):
			move(lastDir.target_position.normalized())
	if Input.is_action_pressed("attack") and weapon and not inventoryOpened:
			emit_signal("swing_weapon", attackSpeed, projectileNum)
	if Input.is_action_just_pressed("inventory"):
		if not inventoryOpened:
			emit_signal("open_inventory", inventory)
			inventoryOpened = true
		else:
			emit_signal("close_inventory")
			inventoryOpened = false


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
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", position + TILESIZE * dir, MOVESPEED).set_trans(Tween.TRANS_SINE)

func equipWeapon (weaponName: String) -> void:
	if weapon:
		weapon.call_deferred("queue_free")
	weapon = load("res://Items/%s/%s.tscn" % [weaponName,weaponName]).instantiate()
	print(weapon.name)
	var pivot = Node2D.new()
	pivot.name = "Weapon_Pivot"
	weapon.position = Vector2(8,0)
	weapon.rotation = PI/2
	add_child(pivot)
	pivot.call_deferred("add_child", weapon)
		
func _on_ground_item_body_entered(body:Node2D, emitter:Node2D) -> void:
	if inventorySize < inventoryWidth * inventoryHeight:
		var emitterName = emitter.name.split("_")[0].to_lower()
		print(emitterName)
		#var item = load("res://Items/%s/%s.tscn" % [emitterName,emitterName]).instantiate()
		inventory[Vector2i(inventorySize % 9, inventorySize / 4)] = emitterName
		inventorySize += 1
		print(inventory)
		emitter.call_deferred("queue_free")



func removeItemFromInventory(inv:Dictionary) -> void:
	inventory = inv
