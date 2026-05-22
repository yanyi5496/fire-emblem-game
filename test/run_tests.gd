#!/usr/bin/env -S godot --headless -s
extends SceneTree

func _initialize() -> void:
	var runner := TestRunner.new()
	runner.run_all()
	runner.free()
	quit(0)
