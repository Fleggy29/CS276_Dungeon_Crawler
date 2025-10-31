class_name Item_holdable extends Area2D

var pivot
var tween: Tween
var reset: bool

func _ready() -> void:
	hide()
	Global.player.swing_weapon.connect(swing)
	pivot = get_parent()
	
func _process(delta: float) -> void:
	if !tween or !tween.is_running():
		hide()
		pivot.rotation = Vector2.UP.angle_to(get_global_mouse_position()-Global.player.global_position) - PI/2
		if reset:
			pivot.position = Vector2(0,0)
			reset = false;
			
func swing(atkSpd:int, projNum:int):
	push_error("Swing Function not defined for %s", name)
