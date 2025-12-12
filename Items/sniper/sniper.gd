extends Item_holdable

@export var projectile: PackedScene

var chance : float = 5
var value : int = 5

func set_stats(bonuses=false, bonuses_list={}):
	cool_down_time = 2.5
	mana_cost = 25
	damage = 5
	projectile_damage = 70
	projectile_speed = 2000
	distance_avoid = 500

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
					p.name = "projectile" + str(i)
					p.speed = projectile_speed
					p.dmg = projectile_damage
					p.rotation = pivot.rotation - PI/2 + (PI/(2*(1+projNum+1)) * (i+1) - PI/4 ) + randf_range(-PI/30, PI/30)
					p.position = global_position
					
					$Spawner.add_child(p)
			reset = true
			#pivot.rotation -= PI/10
			tween = create_tween()
			tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(pivot, "position", pivot.position + (get_global_mouse_position()-Global.player.global_position).normalized()*-5, 0.40).set_trans(Tween.TRANS_LINEAR)
			cooling_down = true
			cool_down()
