extends Item_holdable

@export var projectile: PackedScene

func swing(atkSpd:int, projNum:int):
	show()
	if !tween or !tween.is_running():
		for i in range(0,1+projNum):
			var p = projectile.instantiate()
			p.name = "projectile" + str(i)
			p.speed = 2000
			p.rotation = pivot.rotation - PI/2 + (PI/(2*(1+projNum+1)) * (i+1) - PI/4 ) + randf_range(-PI/30, PI/30)
			p.position = global_position
			
			$Spawner.add_child(p)
		reset = true
		#pivot.rotation -= PI/10
		tween = create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(pivot, "position", pivot.position + (get_global_mouse_position()-Global.player.global_position).normalized()*-5, 0.40).set_trans(Tween.TRANS_LINEAR)
		#tween.tween_property(pivot, "rotation", pivot.rotation + PI/5, float(atkSpd)/4).set_trans(Tween.TRANS_QUAD)
		
