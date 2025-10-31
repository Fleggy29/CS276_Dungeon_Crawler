extends Camera2D


@export var speed: float = 500.0

func _process(delta: float) -> void:
	#var direction := Vector2.ZERO
	#
	## Check arrow key input
	#if Input.is_action_pressed("ui_right"):
		#direction.x += 1
	#if Input.is_action_pressed("ui_left"):
		#direction.x -= 1
	#if Input.is_action_pressed("ui_down"):
		#direction.y += 1
	#if Input.is_action_pressed("ui_up"):
		#direction.y -= 1
#
	## Move camera
	#if direction != Vector2.ZERO:
		#position += direction.normalized() * speed * delta
	pass
