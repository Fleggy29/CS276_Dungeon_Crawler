class_name GroundItem extends Area2D
signal ground_item_body_entered(body:Node2D, emitter:Node2D)

#func _init(player:Player) -> void:
	#self.ground_item_body_entered.connect(player._on_ground_item_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		emit_signal("ground_item_body_entered", body, self)
