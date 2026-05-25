extends RefCounted

class_name TestGameStateFlow

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	GameState.reset()
	GameState.begin_battle("mvp_map_01", 3)
	GameState.current_chapter = "chapter_01"
	GameState.gold = 120
	GameState.inventory = ["iron_sword"]
	GameState.battle_units = [{"unit_id": "hero_001", "x": 1, "y": 1, "current_hp": 18}]
	GameState.battle_map_state = {"map_id": "mvp_map_01", "turn": 3}
	GameState.story_flags = {"intro_done": true}
	GameState.completed_maps = ["mvp_map_00"]
	GameState.resume_scene = "battle"
	GameState.latest_battle_result = "defeat"
	GameState.latest_battle_map_id = "mvp_map_01"
	GameState.latest_battle_turns = 3

	var save_data := GameState.to_dict()
	if save_data.get("map_id", "") == "mvp_map_01" and save_data.get("turn", 0) == 3 and save_data.get("units", []).size() == 1 and save_data.get("resume_scene", "") == "battle":
		details.append("PASS: GameState.to_dict keeps battle session state")
	else:
		details.append("FAIL: GameState.to_dict lost map_id or turn")
		all_pass = false

	var valid_save := save_data.duplicate()
	valid_save["version"] = SaveManager.SAVE_VERSION
	valid_save["timestamp"] = 123456
	valid_save["settings"] = {}
	if SaveManager._validate_version(valid_save):
		details.append("PASS: save schema validation accepts current version")
	else:
		details.append("FAIL: save schema validation rejected current version")
		all_pass = false

	var legacy_save := {
		"version": "1.0.0",
		"timestamp": 123456,
		"chapter": "chapter_01",
		"turn_number": 2,
		"inventory": [],
		"gold": 0,
		"story_flags": {},
		"settings": {},
	}
	if not SaveManager._validate_version(legacy_save):
		details.append("PASS: save schema validation rejects legacy format")
	else:
		details.append("FAIL: save schema validation accepted legacy format")
		all_pass = false

	GameState.set_phase(GameState.GamePhase.STORY)
	GameState.reset()
	if GameState.current_phase == GameState.GamePhase.NONE:
		details.append("PASS: reset clears phase back to NONE")
	else:
		details.append("FAIL: reset did not clear phase")
		all_pass = false

	GameState.battle_units = [{"unit_id": "hero_001", "x": 1, "y": 1, "current_hp": 18, "action_state": 2}]
	GameState.battle_map_state = {"map_id": "mvp_map_01", "turn": 5}
	GameState.resume_scene = "battle"
	GameState.latest_battle_result = "defeat"
	GameState.latest_battle_map_id = "mvp_map_01"
	GameState.latest_battle_turns = 5
	var roundtrip_data := GameState.to_dict()
	GameState.reset()
	GameState.from_dict(roundtrip_data)
	if GameState.battle_units.size() == 1 and GameState.battle_units[0].get("current_hp", 0) == 18:
		details.append("PASS: battle snapshot roundtrip preserves units and HP")
	else:
		details.append("FAIL: battle snapshot roundtrip lost units or HP")
		all_pass = false
	if GameState.battle_map_state.get("turn", 0) == 5:
		details.append("PASS: battle snapshot roundtrip preserves map_state")
	else:
		details.append("FAIL: battle snapshot roundtrip lost map_state")
		all_pass = false
	if GameState.get_resume_scene() == "battle" and GameState.latest_battle_result == "defeat":
		details.append("PASS: roundtrip preserves resume route and latest battle result")
	else:
		details.append("FAIL: roundtrip lost resume route or latest battle result")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "GameState and save schema %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
