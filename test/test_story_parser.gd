extends RefCounted

class_name TestStoryParser

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var parser_script := preload("res://scripts/story/story_parser.gd")

	var sample := "[Narrator]\n这是一个叙述。\n\n[Character: 艾克]\n你出发吧。\n\n[Character: 琳娜]\n你还好吗？\n\n[BGM: battle]\n\n[Event: load_map]"
	var lines := parser_script.parse_story_from_string(sample)
	if lines.is_empty():
		details.append("FAIL: parse_story returned empty")
		all_pass = false
		return {"passed": false, "message": "Parser failed", "details": ["parse_story returned empty"]}

	var narrator_count := 0
	var character_count := 0
	var dialogue_count := 0
	var event_count := 0
	var bgm_count := 0

	for line in lines:
		match line.get("type", -1):
			parser_script.LineType.NARRATOR:
				narrator_count += 1
			parser_script.LineType.CHARACTER:
				character_count += 1
			parser_script.LineType.DIALOGUE:
				dialogue_count += 1
			parser_script.LineType.EVENT:
				event_count += 1
			parser_script.LineType.BGM:
				bgm_count += 1

	var checks := {
		"narrator": [narrator_count, 1],
		"character": [character_count, 2],
		"dialogue": [dialogue_count, 3],
		"event": [event_count, 1],
		"bgm": [bgm_count, 1]
	}
	for key in checks:
		var got: int = checks[key][0]
		var exp: int = checks[key][1]
		if got == exp:
			details.append("PASS: parsed %d %s" % [exp, key])
		else:
			details.append("FAIL: expected %d %s got %d" % [exp, key, got])
			all_pass = false

	var has_load_map := false
	for line in lines:
		if line.get("type", -1) == parser_script.LineType.EVENT and line.get("event_id", "") == "load_map":
			has_load_map = true
	if has_load_map:
		details.append("PASS: event load_map parsed correctly")
	else:
		details.append("FAIL: event load_map not found")
		all_pass = false

	var empty_input := parser_script.parse_story_from_string("")
	if empty_input.is_empty():
		details.append("PASS: empty input returns empty array")
	else:
		details.append("FAIL: empty input should be empty")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Story parser %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
