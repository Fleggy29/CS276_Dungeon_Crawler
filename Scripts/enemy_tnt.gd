class_name Enemy_tnt
extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var spawner = $Spawner
@onready var tnt = preload("res://Scenes/tnt.tscn")
#@onready var world = $"../WorldGenerator"
#@onready var attack_hitbox = $CollisionShapeAttackAside
@onready var detection_area = $"Detection Area"
#@onready var player = $"../Player"
var player
var world
@onready var nav = $"NavigationAgent2D"
@onready var follow_sign = $FollowSign
var is_attacking = false
var current_goal = Vector2i.ZERO
var chasing = false
var returning = false
var retreating = false
var cooling_down = false
var disabled_attack = false
var player_attackable = false
var following = false
var not_safe = false
var speed = 100
var health = 300
var attack = 100
var room_rect: Rect2i = Rect2i(Vector2i(0, 0), Vector2(1600, 1200))
var start_area = room_rect.position + room_rect.size / 2
var PATROOL_AREA_SIZE = Vector2i(600, 600)
var patrool_area = Rect2i(start_area - PATROOL_AREA_SIZE, PATROOL_AREA_SIZE)
var sizer
var id = -1
var last_pos
var move_tolerance = 10
var still_time = 0.0
var threshold_time = 2.0

var highlightCol = Color(255,255,255,0)

func updateHighlightColour():
	var config = ConfigFile.new()
	var err = config.load("res://SaveData/settings.config")

	if err != OK:
		return

	highlightCol = config.get_value("Highlight", "enemy", highlightCol)
	$Highlight.color = highlightCol


func _ready() -> void:
	follow_sign.visible = false
	#print(player,id)
	#print(player, 2, id)
	updateHighlightColour()
	last_pos = global_position
	#print(world ,id)
	patrool()

func init(pos, i, hp):
	start_area = pos
	position = start_area
	patrool_area = Rect2i(start_area - PATROOL_AREA_SIZE / 2, PATROOL_AREA_SIZE)
	id = i
	health = hp
	#print(follow_sign)

func _physics_process(delta: float) -> void:
	anim.play()
	var velocity = Vector2.ZERO # The player's movement vector.
	#if player_attackable and not cooling_down and not retreating:
		#start_attack()
	if cooling_down:
		pass
	elif following:
		nav.target_position = player.global_position
		if nav.distance_to_target() > 600:
			print("I have missed the player")
			nav.target_position = start_area
			follow_sign.visible = false
			returning = true
			chasing = false
			following = false
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
			if velocity.x > 0:
				detection_area.scale.x = 1
			else:
				detection_area.scale.x = -1
	else:
		if not is_attacking:
			anim.animation = "default"
	if not (abs(position.x - nav.target_position.x) < 10 and abs(position.y - nav.target_position.y) < 10):
		_on_navigation_agent_2d_velocity_computed(velocity)
		#velocity = * delta
		move_and_slide()
	#if_stuck(delta)
	#else:
		#patrool()
	
func if_stuck(delta):
	#var old = global_position
	#await get_tree().create_timer(5.0).timeout
	if (abs(global_position.x - last_pos.x) < 1 and abs(global_position.y - last_pos.y) < 1):
		still_time += delta
	else:
		still_time = 0.0
	if still_time > 3.0:
		chasing = false
		returning = true
		retreating = false
		cooling_down=false
		disabled_attack = false
		player_attackable = false
		still_time = 0.0
		patrool()
	last_pos = global_position
	

func patrool():
	var satisfy = false
	var possible_goal = Vector2i.ZERO
	#print(world.get_terrain(global_position))
	##print(world.get_terrain(global_position)["ground"])
	#print(position)
	#print(patrool_area)
	while !satisfy:
		var x = randi_range(patrool_area.position.x, patrool_area.position.x + patrool_area.size.x - 1)
		var y = randi_range(patrool_area.position.y, patrool_area.position.y + patrool_area.size.y - 1)
		possible_goal = Vector2i(x, y)
		#print(world.get_terrain(global_position))
		#print(world.get_terrain(global_position)["walkable_rock"])
		if world.get_terrain(possible_goal)["walkable_rock"] or world.get_terrain(possible_goal)["ground"]:
			satisfy = true
	current_goal = possible_goal
	nav.target_position = current_goal


func death(dmg=100):
	health -= dmg
	if health < 0:
		player.enemies_following.remove_at(player.enemies_following.find(self))
		player.enemiesKilled += 1
		runState.enemiesKilled = player.enemiesKilled
		queue_free()


func start_attack():
	if disabled_attack:
		return
	is_attacking = true
	anim.animation = "through_1"
	await anim.animation_finished
	var p = tnt.instantiate()
	p.player = player
	p.sender = self
	#p.start = position
	spawner.add_child(p)
	anim.animation = "through_2"
	await anim.animation_finished
	is_attacking = false
	retreat()
	
func retreat(dist=400, swing=false, strafe=false):
	if nav.distance_to_target() < dist:
		retreating = true
		#print(position, id)
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
		if strafe:
			dist_to_run = randf_range(3, 5) 
		var new_pos = Vector2(local) - vect * dist_to_run
		new_pos.x *= 64
		new_pos.y *= 64
		nav.target_position = new_pos
		#if_stuck()
		cool_down(swing)


func cool_down(swing):
	cooling_down = true
	speed = 150
	disabled_attack = true
	var time = 1.0
	if swing:
		time = 0.3
	await get_tree().create_timer(time).timeout
	await get_tree().create_timer(time).timeout
	speed = 100
	cooling_down = false
	retreating = false
	if !not_safe and player_attackable and chasing:
		start_attack()
	else:
		retreat()
		
	
	
func attacked():
	pass
	

func _on_area_2d_body_entered(body) -> void:
	if body == player:
		print("I have spotted the player")
		player_attackable = true
		if not chasing:
			player.enemies_following.append(self)
		follow_sign.visible = true
		chasing = true
		print("I am chasing the Player")
		nav.target_position = player.global_position
		start_attack()


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity


func _on_attack_start_body_entered(body: Node2D) -> void:
	if body == player and chasing:
		print("The Player is in the attack range")
		#print(1)through
		player_attackable = true
		#start_attack()
		following = false


func _on_attack_start_body_exited(body: Node2D) -> void:
	if body == player and chasing:
		print("The Player is not in the attack range - starting following")
		player_attackable = false
		following = true


func _on_attack_escape_body_entered(body: Node2D) -> void:
	if body == player:
		not_safe = true
		#print(retreating, chasing, cooling_down)
		#retreat(100, false, true)
		#if not retreating:
			#retreat(100, false, true)


func _on_attack_escape_body_exited(body: Node2D) -> void:
	if body == player:
		not_safe = false
