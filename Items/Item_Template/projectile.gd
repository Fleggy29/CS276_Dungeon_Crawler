class_name Projectile
extends CharacterBody2D

@export var once = false
signal hitEnemy
@export var speed = 100
var dmg = 80
#z_index = 4

func _ready() -> void:
	z_index = 4
	

func _physics_process(delta: float) -> void:
	velocity = Vector2(sin(-rotation),cos(-rotation)) * speed
	var collision = move_and_collide(velocity*delta)
	if collision:
		if collision.get_collider() is not Player:
			if once:
				#print("blew up against ", collision.get_collider(), " whose parent is ", get_parent())
				if collision.get_collider() is Enemy:
					collision.get_collider().death(dmg)
				queue_free()
			else:
				once = true
