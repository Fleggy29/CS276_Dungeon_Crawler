extends Area2D
@onready var player = $"../Player"

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if not player.enemies_following:
			self.monitoring = false  # prevent double triggers
			Global.shouldGenerate = true
			Global.seed = 0
			body.levelsCompleted += 1
			runState.levelsCompleted = body.levelsCompleted
			player.lvls_passed += 1
			#print(player.lvls_passed)
			SceneManager.restart_scene("res://global.tscn")
