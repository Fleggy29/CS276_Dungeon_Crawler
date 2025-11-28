class_name Enemy
extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var world = $"../WorldGenerator"
#@onready var attack_hitbox = $CollisionShapeAttackAside
@onready var detection_area = $"Detection Area"
@export var player: Player
@export var nav: NavigationAgent2D
var is_attacking = false
var current_goal = Vector2i.ZERO
var chasing = false
var returning = false
var retreating = false
var cooling_down = false
var disabled_attack = false
var player_attackable = false
var speed = 150
var patrool_area
var start_area
var PATROOL_AREA_SIZE = Vector2i(200, 200)


func _ready() -> void:
	var room_rect: Rect2i = Rect2i(Vector2i(0, 0), get_viewport().get_visible_rect().size)
	position = room_rect.position + room_rect.size / 2
	start_area = room_rect.position + room_rect.size / 2
	patrool_area = Rect2i(start_area - PATROOL_AREA_SIZE, PATROOL_AREA_SIZE)
	patrool()


func _physics_process(delta: float) -> void:
	anim.play()
	var velocity = Vector2.ZERO # The player's movement vector.
	if cooling_down:
		pass
	elif chasing:
		nav.target_position = player.global_position
		if nav.distance_to_target() > 500:
			nav.target_position = start_area
			returning = true
			chasing = false
			player.enemies_following.remove_at(player.enemies_following.find(self))
	elif not returning:
		if abs(position.x - current_goal.x) < 32 and abs(position.y - current_goal.y) < 32:
			patrool()
	else:
		if abs(position.x - start_area.x) < 32 and abs(position.y - start_area.y) < 32:
			returning = false
			patrool()
	if nav.target_position:
		var next = nav.get_next_path_position();
		velocity = global_position.direction_to(next) * speed;
	if velocity != Vector2.ZERO:
		if not is_attacking:
			anim.animation = "walk"
		velocity = velocity.normalized() * speed
		if not cooling_down:
			anim.flip_h = velocity.x < 0
	else:
		if not is_attacking:
			anim.animation = "default"
	if not (abs(position.x - nav.target_position.x) < 10 and abs(position.y - nav.target_position.y) < 10):
		_on_navigation_agent_2d_velocity_computed(velocity)
		#velocity = * delta
		move_and_slide()
	

func patrool():
	var x = randi_range(patrool_area.position.x, patrool_area.position.x + patrool_area.size.x - 1)
	var y = randi_range(patrool_area.position.y, patrool_area.position.y + patrool_area.size.y - 1)
	current_goal = Vector2i(x, y)
	nav.target_position = current_goal


func death():
	queue_free()


func start_attack():
	if disabled_attack:
		return
	is_attacking = true
	anim.animation = "hit_aside"
	await anim.animation_finished
	is_attacking = false
	retreat()
	
func retreat(dist=100, swing=false):
	if nav.distance_to_target() < dist and not retreating:
		retreating = true
		var local = world.get_map_position(position)
		var diff = nav.get_next_path_position() - position
		var vect = Vector2i.ZERO
		if -20 < diff.x and diff.x < 20:
			pass
		elif diff.x < 0:
			vect.x = -1
		else:
			vect.x = 1 
		if -20 < diff.y and diff.y < 20:
			pass
		elif diff.y < 0:
			vect.y = -1
		else:
			vect.y = 1 
		var dist_to_run = randf_range(1.5, 3)
		var new_pos = Vector2(local) - vect * dist_to_run
		new_pos.x *= 64
		new_pos.y *= 64
		nav.target_position = new_pos
		cool_down(swing)


func cool_down(swing):
	cooling_down = true
	speed = 300
	disabled_attack = true
	var time = 0.8
	if swing:
		time = 0.3
	await get_tree().create_timer(time).timeout
	disabled_attack = false
	if player_attackable:
		start_attack()
	await get_tree().create_timer(time).timeout
	speed = 150
	cooling_down = false
	retreating = false
	
	
func attacked():
	pass
	

func _on_area_2d_body_entered(body) -> void:
	if body == player:
		if not chasing:
			player.enemies_following.append(self)
		chasing = true
		nav.target_position = player.global_position


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity


func _on_attack_start_body_entered(body: Node2D) -> void:
	if body == player:
		player_attackable = true
		start_attack()


func _on_attack_start_body_exited(body: Node2D) -> void:
	if body == player:
		player_attackable = false
