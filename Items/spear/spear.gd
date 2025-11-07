extends Item_holdable

#func swing(atkSpd:int, projNum:int):
	#show()
	#if !tween or !tween.is_running():
		#pivot.rotation -= PI/4
		#tween = create_tween()
		#tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		#tween.tween_property(pivot, "rotation", pivot.rotation + PI/2, float(atkSpd)/4).set_trans(Tween.TRANS_QUAD)

func swing(atkSpd:int, projNum:int):
	show()
	if !tween or !tween.is_running():
		reset = true;
		tween = create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(pivot, "position", pivot.position + (get_global_mouse_position()-Global.player.global_position).normalized()*5, 0.10).set_trans(Tween.TRANS_LINEAR)
