extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var attack_hitbox = $CollisionShapeAttackAside
var is_attacking = false

func _ready() -> void:
	var room_rect: Rect2i = Rect2i(Vector2i(0, 0), get_viewport().get_visible_rect().size)
	attack_hitbox.disabled = true
	position = room_rect.position + room_rect.size / 2

func _process(delta: float) -> void:
	anim.play()
	var speed = 400
	var velocity = Vector2.ZERO # The player's movement vector.
	velocity.x = Input.get_axis("ui_left", "ui_right")   # A/D or ←/→ (if mapped)
	velocity.y = Input.get_axis("ui_up", "ui_down")
	if Input.is_action_just_pressed("ui_accept") and not is_attacking:
		print('yes')
		start_attack()

	if velocity != Vector2.ZERO:
		if not is_attacking:
			anim.animation = "walk"
		velocity = velocity.normalized() * speed
		anim.flip_h = velocity.x < 0
	else:
		if not is_attacking:
			anim.animation = "default"
	position += velocity * delta
	move_and_slide()
	
func start_attack():
	print("no")
	is_attacking = true
	anim.animation = "hit_aside"
	attack_hitbox.disabled = false
	#anim.play()
	await anim.animation_finished
	print("maybe")
	attack_hitbox.disabled = true
	is_attacking = false
