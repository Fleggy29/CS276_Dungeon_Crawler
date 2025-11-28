extends Item_holdable

@export var projectile: PackedScene

func swing(atkSpd:int, projNum:int):
	show()
	if !tween or !tween.is_running():
		for i in range(0,3+projNum):
			var p = projectile.instantiate()
			p.name = "projectile" + str(i)
			p.speed = 400
			p.rotation = pivot.rotation - PI/2 + (PI/(2*(3+projNum+1)) * (i+1) - PI/4)
			p.position = global_position
			
			$Spawner.add_child(p)
		reset = true;
		pivot.rotation -= PI/10
		tween = create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(pivot, "position", pivot.position + (get_global_mouse_position()-Global.player.global_position).normalized()*5, 0.10).set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(pivot, "rotation", pivot.rotation + PI/5, float(atkSpd)/4).set_trans(Tween.TRANS_QUAD)
		
