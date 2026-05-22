extends RefCounted

class_name StoryParser

enum LineType { NARRATOR, CHARACTER, CHOICE, CONDITION, EVENT, BGM, CG, EFFECT, DIALOGUE, UNKNOWN }

static func parse_line(raw: String) -> Dictionary:
	raw = raw.strip_edges()
	if raw.begins_with("[Narrator]"):
		return { "type": LineType.NARRATOR, "content": "" }
	if raw.begins_with("[Character:"):
		var name_part := raw.trim_prefix("[Character:").trim_prefix(" ")
		var end := name_part.find("]")
		if end >= 0:
			return { "type": LineType.CHARACTER, "name": name_part.substr(0, end).strip_edges(), "content": "" }
	if raw.begins_with("[Choice]"):
		return { "type": LineType.CHOICE, "content": "" }
	if raw.begins_with("[Condition:"):
		var cond_part := raw.trim_prefix("[Condition:").trim_prefix(" ")
		var end := cond_part.find("]")
		if end >= 0:
			return { "type": LineType.CONDITION, "flag": cond_part.substr(0, end).strip_edges(), "content": "" }
	if raw.begins_with("[Event:"):
		var event_part := raw.trim_prefix("[Event:").trim_prefix(" ")
		var end := event_part.find("]")
		if end >= 0:
			return { "type": LineType.EVENT, "event_id": event_part.substr(0, end).strip_edges(), "content": "" }
	if raw.begins_with("[BGM:"):
		var bgm_part := raw.trim_prefix("[BGM:").trim_prefix(" ")
		var end := bgm_part.find("]")
		if end >= 0:
			return { "type": LineType.BGM, "bgm_id": bgm_part.substr(0, end).strip_edges(), "content": "" }
	if raw.begins_with("[CG:"):
		var cg_part := raw.trim_prefix("[CG:").trim_prefix(" ")
		var end := cg_part.find("]")
		if end >= 0:
			return { "type": LineType.CG, "cg_id": cg_part.substr(0, end).strip_edges(), "content": "" }
	if raw.begins_with("[Effect:"):
		var effect_part := raw.trim_prefix("[Effect:").trim_prefix(" ")
		var end := effect_part.find("]")
		if end >= 0:
			return { "type": LineType.EFFECT, "effect_id": effect_part.substr(0, end).strip_edges(), "content": "" }
	if raw.strip_edges().length() > 0:
		return { "type": LineType.DIALOGUE, "content": raw }
	return { "type": LineType.UNKNOWN, "content": raw }

static func parse_story(file_path: String) -> Array[Dictionary]:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Story file not found: ", file_path)
		return []
	var lines: Array[Dictionary] = []
	while file.get_position() < file.get_length():
		var line := file.get_line()
		if line.strip_edges().is_empty():
			continue
		var parsed := parse_line(line)
		if parsed.type != LineType.UNKNOWN:
			lines.append(parsed)
	return lines
