extends RefCounted

class_name TestBattleLifecycleService

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var service = preload("res://scripts/battle/battle_lifecycle_service.gd").new()
	var unit_scene := preload("res://scenes/battle/unit/unit.tscn")

	var container := Node.new()
	var mock_unit = unit_scene.instantiate()
	mock_unit.setup("hero_001", "player", Vector2i(1, 1))
	mock_unit.take_damage(2)
	container.add_child(mock_unit)

	var snapshot: Dictionary = service.build_snapshot(container, 5, "mvp_map_01")
	if snapshot.get("units", []).size() == 1:
		details.append("PASS: build_snapshot includes unit data")
	else:
		details.append("FAIL: build_snapshot units count expected 1 got %d" % snapshot.get("units", []).size())
		all_pass = false

	var unit_data: Dictionary = snapshot["units"][0]
	if unit_data.get("unit_id", "") == "hero_001":
		details.append("PASS: unit data contains correct unit_id")
	else:
		details.append("FAIL: unit_id expected hero_001 got %s" % unit_data.get("unit_id", ""))
		all_pass = false

	var map_state: Dictionary = snapshot.get("map_state", {})
	if map_state.get("turn", 0) == 5:
		details.append("PASS: snapshot map_state includes turn number")
	else:
		details.append("FAIL: turn expected 5 got %d" % map_state.get("turn", 0))
		all_pass = false
	if map_state.get("map_id", "") == "mvp_map_01":
		details.append("PASS: snapshot map_state includes map_id")
	else:
		details.append("FAIL: map_id expected mvp_map_01 got %s" % map_state.get("map_id", ""))
		all_pass = false

	GameState.reset()
	GameState.current_chapter = "chapter_01"
	var battle_result: Dictionary = service.finalize_battle("victory", container, 8, "mvp_map_01", "chapter_01")
	if battle_result.get("saved", false):
		details.append("PASS: finalize_battle returns saved=true")
	else:
		details.append("FAIL: finalize_battle should return saved=true")
		all_pass = false
	if GameState.latest_battle_result == "victory" and GameState.latest_battle_map_id == "mvp_map_01":
		details.append("PASS: finalize_battle writes battle result to GameState")
	else:
		details.append("FAIL: battle result not recorded in GameState")
		all_pass = false
	if GameState.latest_battle_turns == 8:
		details.append("PASS: finalize_battle records turn count")
	else:
		details.append("FAIL: turns expected 8 got %d" % GameState.latest_battle_turns)
		all_pass = false
	if GameState.get_resume_scene() == "result":
		details.append("PASS: finalize_battle sets resume_scene to result")
	else:
		details.append("FAIL: resume_scene expected result got %s" % GameState.get_resume_scene())
		all_pass = false
	if "mvp_map_01" in GameState.completed_maps:
		details.append("PASS: finalize_battle appends to completed_maps")
	else:
		details.append("FAIL: mvp_map_01 not in completed_maps")
		all_pass = false
	if GameState.story_flags.get("chapter_01_cleared", false):
		details.append("PASS: finalize_battle sets chapter_01_cleared flag")
	else:
		details.append("FAIL: chapter_01_cleared flag not set")
		all_pass = false

	container.free()

	return {
		"passed": all_pass,
		"message": "Battle lifecycle service %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
