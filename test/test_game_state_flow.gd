extends RefCounted

class_name TestGameStateFlow

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	GameState.reset()
	GameState.current_map_id = "mvp_map_01"
	GameState.turn_number = 3
	GameState.current_chapter = "chapter_01"
	GameState.gold = 120
	GameState.inventory = ["iron_sword"]
	GameState.story_flags = {"intro_done": true}
	GameState.completed_maps = ["mvp_map_00"]

	var save_data := GameState.to_dict()
	if save_data.get("map_id", "") == "mvp_map_01" and save_data.get("turn", 0) == 3:
		details.append("PASS: GameState.to_dict keeps battle session state")
	else:
		details.append("FAIL: GameState.to_dict lost map_id or turn")
		all_pass = false

	var version_check := SaveManager.SAVE_VERSION == "1.0.0"
	if version_check:
		details.append("PASS: save schema version is current")
	else:
		details.append("FAIL: unexpected SAVE_VERSION")
		all_pass = false

	GameState.set_phase(GameState.GamePhase.STORY)
	GameState.reset()
	if GameState.current_phase == GameState.GamePhase.NONE:
		details.append("PASS: reset clears phase back to NONE")
	else:
		details.append("FAIL: reset did not clear phase")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "GameState and save schema %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
