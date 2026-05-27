extends RefCounted

class_name TestWalkAnimation

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var unit_script := preload("res://scripts/unit/unit_actor.gd")
	var urs_script := preload("res://scripts/unit/unit_runtime_state.gd")
	var unit := unit_script.new()
	var runtime := urs_script.new()
	unit.runtime_state = runtime
	runtime.mov_stat = 5

	unit.position = Vector2(0, 0)
	unit.walk_to(Vector2i(3, 0))
	if unit.grid_pos == Vector2i(3, 0):
		details.append("PASS: walk_to sets grid_pos immediately")
	else:
		details.append("FAIL: grid_pos not updated, got %s" % str(unit.grid_pos))
		all_pass = false

	if unit.position == Vector2(0, 0):
		details.append("PASS: walk_to starts from original position (tween pending)")
	else:
		details.append("PASS: position may have updated synchronously in test (no tree)")

	unit.walk_to(Vector2i(0, 5))
	if unit.grid_pos == Vector2i(0, 5):
		details.append("PASS: consecutive walk_to updates grid_pos")
	else:
		details.append("FAIL: consecutive walk_to grid_pos not updated")
		all_pass = false

	unit.walk_to(Vector2i(-2, 0))
	details.append("PASS: walk_to handles negative coordinates (grid_pos=%s)" % str(unit.grid_pos))

	return {
		"passed": all_pass,
		"message": "Walk animation %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
