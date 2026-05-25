extends RefCounted

class_name TestSaveLoadFlow

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	GameState.reset()
	GameState.current_chapter = "chapter_01"
	GameState.current_map_id = "mvp_map_01"
	GameState.turn_number = 3
	GameState.gold = 100
	GameState.inventory = ["iron_sword", "heal_staff"]
	GameState.story_flags = {"intro_done": true}
	GameState.completed_maps = ["mvp_map_00"]
	GameState.set_resume_scene("result")
	GameState.latest_battle_result = "victory"
	GameState.latest_battle_map_id = "mvp_map_01"
	GameState.latest_battle_turns = 3

	var save_data := GameState.to_dict()
	save_data["version"] = SaveManager.SAVE_VERSION
	save_data["timestamp"] = Time.get_unix_time_from_system()
	save_data["settings"] = {}

	if SaveManager._validate_version(save_data):
		details.append("PASS: _validate_version accepts complete save data")
	else:
		details.append("FAIL: _validate_version rejected valid data")
		all_pass = false

	var missing_field_data := save_data.duplicate()
	missing_field_data.erase("gold")
	if not SaveManager._validate_version(missing_field_data):
		details.append("PASS: _validate_version rejects data missing 'gold'")
	else:
		details.append("FAIL: _validate_version should reject missing field")
		all_pass = false

	var old_version := save_data.duplicate()
	old_version["version"] = "1.0.0"
	if not SaveManager._validate_version(old_version):
		details.append("PASS: _validate_version rejects old version 1.0.0")
	else:
		details.append("FAIL: old version should be rejected")
		all_pass = false

	var migrated := save_data.duplicate()
	migrated.erase("turn")
	migrated["turn_number"] = 5
	migrated["version"] = "1.5.0"
	SaveManager._migrate(migrated)
	if migrated.get("turn", 0) == 5 and migrated.get("version", "") == SaveManager.SAVE_VERSION:
		details.append("PASS: _migrate converts turn_number -> turn and updates version")
	else:
		details.append("FAIL: migration failed: turn=%s version=%s" % [migrated.get("turn"), migrated.get("version")])
		all_pass = false

	var legacy_no_chapter := save_data.duplicate()
	legacy_no_chapter.erase("chapter")
	legacy_no_chapter["map_id"] = "mvp_map_01"
	legacy_no_chapter["version"] = "1.5.0"
	SaveManager._migrate(legacy_no_chapter)
	if legacy_no_chapter.get("chapter", "") == "mvp_map_01":
		details.append("PASS: _migrate copies map_id to chapter when missing")
	else:
		details.append("FAIL: chapter migration failed")
		all_pass = false

	var legacy_runtime_save := {
		"version": "1.5.0",
		"timestamp": Time.get_unix_time_from_system(),
		"map_id": "mvp_map_01",
		"turn_number": 4,
		"gold": 10,
		"inventory": [],
		"story_flags": {},
		"completed_maps": [],
		"settings": {},
	}
	SaveManager._migrate(legacy_runtime_save)
	if SaveManager._validate_version(legacy_runtime_save) and legacy_runtime_save.get("resume_scene", "") == "battle":
		details.append("PASS: _migrate backfills runtime save fields for legacy battle save")
	else:
		details.append("FAIL: legacy runtime save was not normalized into current schema")
		all_pass = false

	var roundtrip := save_data.duplicate()
	GameState.reset()
	GameState.from_dict(roundtrip)
	if GameState.current_chapter == "chapter_01" and GameState.current_map_id == "mvp_map_01":
		details.append("PASS: to_dict -> from_dict roundtrip preserves chapter and map_id")
	else:
		details.append("FAIL: roundtrip lost chapter/map_id")
		all_pass = false
	if GameState.gold == 100 and GameState.turn_number == 3:
		details.append("PASS: roundtrip preserves gold and turn")
	else:
		details.append("FAIL: roundtrip lost gold/turn")
		all_pass = false
	if GameState.get_resume_scene() == "result" and GameState.latest_battle_result == "victory":
		details.append("PASS: roundtrip preserves resume_scene and latest battle metadata")
	else:
		details.append("FAIL: roundtrip lost resume routing or battle result metadata")
		all_pass = false

	GameState.story_flags = {"intro_done": true, "post_battle_pending": false}
	var flags_copy := GameState.to_dict().get("story_flags", {})
	if flags_copy.get("intro_done", false) == true and flags_copy.get("post_battle_pending", true) == false:
		details.append("PASS: to_dict preserves boolean flags correctly")
	else:
		details.append("FAIL: boolean flag preservation failed")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Save/load flow %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
