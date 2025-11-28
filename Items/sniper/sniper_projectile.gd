extends Projectile


func _physics_process(delta: float) -> void:
	velocity = Vector2(sin(-rotation),cos(-rotation)) * speed
	var collision = move_and_collide(velocity*delta)
	if collision:
		if collision.get_collider() is not Player:
			if collision.get_collider() is Enemy:
				collision.get_collider().death()
			elif once:
				print("blew up against ", collision.get_collider(), " whose parent is ", get_parent())
				
					
				queue_free()
			else:
				once = true
