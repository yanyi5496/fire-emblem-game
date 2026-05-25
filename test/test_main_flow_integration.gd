extends RefCounted

class_name TestMainFlowIntegration

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	GameState.reset()

	GameState.set_phase(GameState.GamePhase.TITLE)
	GameState.set_resume_scene("main_menu")
	if GameState.current_phase == GameState.GamePhase.TITLE and GameState.get_resume_scene() == "main_menu":
		details.append("PASS: TITLE -> resume_scene=main_menu")
	else:
		details.append("FAIL: TITLE phase setup")
		all_pass = false

	GameState.current_chapter = "chapter_01"
	GameState.current_map_id = "mvp_map_01"
	GameState.set_phase(GameState.GamePhase.STORY)
	GameState.set_resume_scene("story")
	if GameState.current_phase == GameState.GamePhase.STORY and GameState.current_map_id == "mvp_map_01":
		details.append("PASS: STORY -> map_id preserved, resume_scene=story")
	else:
		details.append("FAIL: STORY phase transition lost map_id")
		all_pass = false

	GameState.begin_battle("mvp_map_01", 1)
	GameState.set_phase(GameState.GamePhase.BATTLE_PREP)
	if GameState.current_map_id == "mvp_map_01" and GameState.turn_number == 1:
		details.append("PASS: BATTLE -> begin_battle sets map and turn")
	else:
		details.append("FAIL: BATTLE phase lost map/turn")
		all_pass = false

	GameState.record_battle_result("victory", "mvp_map_01", 5)
	GameState.set_resume_scene("result")
	GameState.set_phase(GameState.GamePhase.BATTLE_RESULT)
	if GameState.latest_battle_result == "victory" and GameState.latest_battle_turns == 5:
		details.append("PASS: BATTLE_RESULT -> records victory + turn count")
	else:
		details.append("FAIL: BATTLE_RESULT did not record result")
		all_pass = false
	if GameState.get_resume_scene() == "result":
		details.append("PASS: resume_scene set to result after battle")
	else:
		details.append("FAIL: resume_scene should be result after battle")
		all_pass = false

	if "mvp_map_01" not in GameState.completed_maps:
		GameState.completed_maps.append("mvp_map_01")
	GameState.story_flags["chapter_01_cleared"] = true
	GameState.set_phase(GameState.GamePhase.TITLE)
	GameState.set_resume_scene("main_menu")
	if GameState.current_phase == GameState.GamePhase.TITLE and GameState.get_resume_scene() == "main_menu":
		details.append("PASS: TITLE (end) -> resume_scene back to main_menu")
	else:
		details.append("FAIL: end-of-flow should return to TITLE/main_menu")
		all_pass = false

	var save_data := GameState.to_dict()
	save_data["version"] = "1.0.0"
	var restored := save_data.duplicate(true)
	GameState.reset()
	GameState.from_dict(restored)
	if GameState.current_chapter == "chapter_01" and "mvp_map_01" in GameState.completed_maps and GameState.latest_battle_result == "victory":
		details.append("PASS: full flow roundtrip preserves chapter/completed_maps/result")
	else:
		details.append("FAIL: full flow state lost after roundtrip")
		all_pass = false
	if GameState.get_resume_scene() == "main_menu":
		details.append("PASS: resume_scene preserved after roundtrip")
	else:
		details.append("FAIL: resume_scene lost after roundtrip")
		all_pass = false

	GameState.reset()
	if GameState.current_phase == GameState.GamePhase.NONE and GameState.current_map_id == "" and GameState.latest_battle_result == "":
		details.append("PASS: reset clears all flow state")
	else:
		details.append("FAIL: reset should clear flow state")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Main flow integration %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
