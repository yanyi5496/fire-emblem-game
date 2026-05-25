extends RefCounted

class_name TestChapterFlow

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	GameState.reset()
	GameState.current_chapter = "chapter_01"
	GameState.current_map_id = "mvp_map_01"
	GameState.latest_battle_result = "victory"
	GameState.latest_battle_map_id = "mvp_map_01"
	GameState.latest_battle_turns = 5

	if GameState.latest_battle_result == "victory":
		details.append("PASS: battle result recorded as victory")
	else:
		details.append("FAIL: battle result should be victory")
		all_pass = false

	var flag_key := "%s_post_battle_pending" % GameState.current_chapter
	GameState.story_flags[flag_key] = true
	if GameState.story_flags.get(flag_key, false):
		details.append("PASS: post-battle story flag set correctly")
	else:
		details.append("FAIL: post-battle flag should be set")
		all_pass = false

	GameState.story_flags["%s_cleared" % GameState.current_chapter] = true
	if GameState.story_flags.get("chapter_01_cleared", false):
		details.append("PASS: chapter_01 cleared flag set")
	else:
		details.append("FAIL: chapter_01 cleared flag not set")
		all_pass = false

	if "mvp_map_01" not in GameState.completed_maps:
		GameState.completed_maps.append("mvp_map_01")
	if "mvp_map_01" in GameState.completed_maps:
		details.append("PASS: completed_maps contains mvp_map_01")
	else:
		details.append("FAIL: mvp_map_01 should be in completed_maps")
		all_pass = false

	GameState.set_resume_scene("result")
	if GameState.get_resume_scene() == "result":
		details.append("PASS: resume_scene set to result for post-battle")
	else:
		details.append("FAIL: resume_scene should be result")
		all_pass = false

	GameState.set_resume_scene("main_menu")
	if GameState.get_resume_scene() == "main_menu":
		details.append("PASS: resume_scene falls back to main_menu when no next chapter")
	else:
		details.append("FAIL: resume_scene should be main_menu")
		all_pass = false

	var save_data := GameState.to_dict()
	save_data["version"] = "1.0.0"
	var restored := save_data.duplicate(true)
	GameState.reset()
	GameState.from_dict(restored)
	if GameState.current_chapter == "chapter_01" and "mvp_map_01" in GameState.completed_maps:
		details.append("PASS: chapter flow state is persistable via to_dict/from_dict")
	else:
		details.append("FAIL: chapter flow state lost after roundtrip")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Chapter flow %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
