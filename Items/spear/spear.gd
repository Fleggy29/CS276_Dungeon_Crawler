extends Item_holdable

var chance : float = 30
var value : int = 5

func set_stats(bonuses=false, bonuses_list={}):
	cool_down_time = 1.3
	damage = 40
	#print(damage)
	distance_avoid = 350
	

func swing(atkSpd:int, projNum:int):
	if !cooling_down:
		show()
		$CollisionShape2D.disabled = false
		if !tween or !tween.is_running():
			for i in Global.player.enemies_following:
				i.retreat(distance_avoid, true)
			reset = true;
			tween = create_tween()
			tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(pivot, "position", pivot.position + (get_global_mouse_position()-Global.player.global_position).normalized()*5, 1/(10*float(atkSpd))).set_trans(Tween.TRANS_LINEAR)
			#$CollisionShape2D.disabled = true
			cooling_down = true
			cool_down()
