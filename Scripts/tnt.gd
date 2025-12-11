class_name TNT
extends CharacterBody2D
var once = false
@onready var anim = $AnimatedSprite2D
@export var speed = 400
@export var rotation_speed = 20.0
var player
var goal
var start
var in_range = []
var sender

func _ready() -> void:
	position = sender.position
	goal = player.global_position
	var dir = (goal - position).normalized()
	#print(dir)
	velocity = dir * speed
	anim.animation = "default"
	z_index = 4
	
func _process(delta: float) -> void:
	anim.play()

func _physics_process(delta: float) -> void:
	if !once:
		var collision = move_and_collide(velocity*delta)
		rotation += rotation_speed * delta
		if collision or abs(position - goal) < Vector2(64, 64):
			blow_up(collision)
		
				

func blow_up(collision):
	if collision:
		if collision.get_collider() is not Enemy_tnt and collision.get_collider() is not TNT:
			#print(collision.get_collider().name)
			#print("s  ", sender.name)
			once = true
			anim.animation = "blast"
			for i in in_range:
				if i is not Player:
					i.death()
			await anim.animation_finished
			queue_free()
	else:
		once = true
		anim.animation = "blast"
		for i in in_range:
			if i is not Player:
				i.death()
		await anim.animation_finished
		queue_free()



func _on_area_body_entered(body: Node2D) -> void:
	if body is Enemy or body is Player:
		in_range.append(body)
	



func _on_area_body_exited(body: Node2D) -> void:
	if body is Enemy or body is Player:
		in_range.pop_at(in_range.find(body))
