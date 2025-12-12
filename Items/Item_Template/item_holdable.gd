class_name Item_holdable extends Area2D

var pivot
var tween: Tween
var reset: bool
var cooling_down = false
var cool_down_time = 0.5
var damage: float = 5.0
var projectile_damage: float = 5.0
var projectile_speed: float = 5.0
var mana_cost: float = 5.0
var distance_avoid: float = 100.0
var lvl = 1
@onready var player = get_node("/root/Global/Player")

func _ready() -> void:
	hide()
	Global.player.swing_weapon.connect(swing)
	pivot = get_parent()
	connect("body_entered", _on_body_entered)
	set_stats(true, player.bonuses)
	$CollisionShape2D.disabled = true
	if player:
		player.bonuses_updated.connect(update_bonuses)
	adjust_to_lvl()
	
func _process(delta: float) -> void:
	#print(position)
	if !tween or !tween.is_running():
		hide()
		pivot.rotation = Vector2.UP.angle_to(get_global_mouse_position()-Global.player.global_position) - PI/2
		if reset:
			pivot.position = Vector2(0,0)
			reset = false;
	
func swing(atkSpd:int, projNum:int):
	push_error("Swing Function not defined for %s", name)
	
func set_stats(bonuses, bonuses_list):
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is not Player and is_visible_in_tree():
		if body is Enemy:
			body.death(damage)

func cool_down():
	await get_tree().create_timer(cool_down_time).timeout
	cooling_down = false
	$CollisionShape2D.disabled = true
	
func update_bonuses():
	var bonuses_list = player.bonuses
	cool_down_time = cool_down_time * bonuses_list["cool_down_bonus"]
	
func adjust_to_lvl():
	#print(damage, " ",projectile_damage, " ", cool_down_time, " ", mana_cost)
	for j in range(1, lvl + 1):
		var i = float(j)
		#print(i)
		if (j % 2) == 0:
			damage = damage + damage * (i / 5)
		if (j % 3) == 0:
			projectile_damage = projectile_damage + projectile_damage * (i / 5)
		if (j % 4) == 0:
			cool_down_time = max(0, cool_down_time - cool_down_time * (i / 40))
		if (j % 5) == 0:
			mana_cost = max(0, mana_cost - mana_cost * (i / 30))
	#print(damage, " ",projectile_damage, " ", cool_down_time, " ", mana_cost)
	
	
