extends Item_holdable

@export var projectile: PackedScene
#@onready var player = get_node("/root/Global/Player")

var chance : float = 25
var value : int = 5

func set_stats(bonuses=false, bonuses_list={}):
	cool_down_time = 1.2
	mana_cost = 5
	damage = 5
	projectile_damage = 30
	projectile_speed = 800
	distance_avoid = 450

func swing(atkSpd:int, projNum:int):
	if !cooling_down:
		$CollisionShape2D.disabled = false
		show()
		if !tween or !tween.is_running():
			for i in Global.player.enemies_following:
				i.retreat(distance_avoid, true)
			if player.use_mana(mana_cost):
				for i in range(0,1+projNum):
					var p = projectile.instantiate()
					p.dmg = projectile_damage
					p.name = "projectile" + str(i)
					p.speed = projectile_speed
					p.rotation = pivot.rotation - PI/2 + (PI/(2*(1+projNum+1)) * (i+1) - PI/4 ) + randf_range(-PI/12, PI/12)
					p.position = global_position
					
					$Spawner.add_child(p)
			reset = true
			#pivot.rotation -= PI/10
			tween = create_tween()
			tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(pivot, "position", pivot.position + (get_global_mouse_position()-Global.player.global_position).normalized()*-5, 0.40).set_trans(Tween.TRANS_LINEAR)
			cooling_down = true
			cool_down()
