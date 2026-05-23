extends SceneTree

func _initialize() -> void:
	var script = load("res://test/test_scene_contracts.gd")
	if script:
		print("LOAD OK")
	else:
		print("LOAD FAILED")
	quit(0)
