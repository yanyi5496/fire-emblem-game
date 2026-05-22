extends SceneTree

func _initialize() -> void:
	var runner_scene := load("res://test/test_runner.tscn") as PackedScene
	if not runner_scene:
		push_error("Failed to load test runner scene")
		quit(1)
		return
	var runner := runner_scene.instantiate()
	root.add_child(runner)
	runner.run_all()
	quit(0)
