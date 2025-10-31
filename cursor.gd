extends Area2D

const TILESIZE = Global.TILESIZE
const MOVESPEED = 0.25
var tween: Tween

func _process(delta: float) -> void:
	if !tween or !tween.is_running():
		if Input.is_action_pressed("move_left") and position.x > 112+16:
			move(Vector2.LEFT)
		if Input.is_action_pressed("move_right") and position.x < 636-16:
			move(Vector2.RIGHT)
		if Input.is_action_pressed("move_up") and position.y > 112+16:
			move(Vector2.UP)
		if Input.is_action_pressed("move_down") and position.y < 304-16:
			move(Vector2.DOWN)

func move(dir: Vector2):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", position + TILESIZE * dir, MOVESPEED).set_trans(Tween.TRANS_SINE)
