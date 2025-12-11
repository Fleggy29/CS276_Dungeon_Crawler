extends Item_holdable

var chance : float = 40
var value : int = 5

func swing(atkSpd:int, projNum:int):
	show()
	for i in Global.player.enemies_following:
		i.retreat(200, true)
	if !tween or !tween.is_running():
		pivot.rotation -= PI/4
		tween = create_tween()
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(pivot, "rotation", pivot.rotation + PI/2, 1/(4*float(atkSpd))).set_trans(Tween.TRANS_QUAD)
