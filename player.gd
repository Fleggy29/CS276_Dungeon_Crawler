extends CharacterBody2D

const TILESIZE = 32
const MOVESPEED = 0.25
var tween: Tween
var lastDir: Vector2
@export var weapon: PackedScene

func _on_enter_tree():
	Global.player = self

func _physics_process(delta: float) -> void:
	if !tween or !tween.is_running():
		if Input.is_action_pressed("move_left"):
			lastDir = Vector2.LEFT
			move(Vector2.LEFT)
		if Input.is_action_pressed("move_right"):
			lastDir = Vector2.RIGHT
			move(Vector2.RIGHT)
		if Input.is_action_pressed("move_up"):
			lastDir = Vector2.UP
			move(Vector2.UP)
		if Input.is_action_pressed("move_down"):
			lastDir = Vector2.DOWN
			move(Vector2.DOWN)
		if Input.is_action_pressed("attack"):
			pass
		if Input.is_action_pressed("dash"):
			move(lastDir * 2)
			

func move(dir: Vector2):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(self, "position", position + TILESIZE * dir, MOVESPEED).set_trans(Tween.TRANS_SINE)
