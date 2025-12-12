extends Item_holdable

var chance : float = 40
var value : int = 5

func set_stats(bonuses=false, bonuses_list={}):
	cool_down_time = 1.0
	damage = 25
	distance_avoid = 150
	if bonuses_list:
		cool_down_time = cool_down_time * bonuses_list["cool_down_bonus"]
		#print("bonus applied", cool_down_time)


	#print("bonus applied", cool_down_time)
	

func swing(atkSpd:int, projNum:int):
	if !cooling_down:
		$CollisionShape2D.disabled = false
		show()
		if !tween or !tween.is_running():
			for i in Global.player.enemies_following:
				i.retreat(distance_avoid, true)
			pivot.rotation -= PI/4
			tween = create_tween()
			tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(pivot, "rotation", pivot.rotation + PI/2, 1/(4*float(atkSpd))).set_trans(Tween.TRANS_QUAD)
			cooling_down = true
			cool_down()
