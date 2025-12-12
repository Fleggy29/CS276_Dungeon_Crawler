extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		self.monitoring = false  # prevent double triggers
		Global.shouldGenerate = true
		Global.seed = 0
		body.levelsCompleted += 1
		runState.levelsCompleted = body.levelsCompleted

		SceneManager.restart_scene("res://global.tscn")

		
