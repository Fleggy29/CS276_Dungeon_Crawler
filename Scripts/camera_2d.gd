extends Camera2D


@export var speed: float = 500.0



func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Projectile:
		body.call_deferred("queue_free")
