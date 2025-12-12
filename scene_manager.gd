extends Node

func restart_scene(path: String) -> void:
	var tree = get_tree()
	var old_scene = tree.current_scene

	# Load new scene instance
	var new_scene = load(path).instantiate()

	# Add the new scene first
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene

	# Then free the old scene safely
	if old_scene:
		old_scene.get_parent().remove_child(old_scene)
		old_scene.queue_free()
