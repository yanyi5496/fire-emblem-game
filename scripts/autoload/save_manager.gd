extends Node

const SAVE_VERSION := "2.0.0"
const MIN_SUPPORTED_VERSION := "2.0.0"
const MIN_LOADABLE_VERSION := "1.5.0"
const MAX_SLOTS := 10
const MAX_AUTO_SAVES := 5
const REQUIRED_SAVE_FIELDS := [
	"version",
	"timestamp",
	"chapter",
	"map_id",
	"turn",
	"gold",
	"inventory",
	"story_flags",
	"completed_maps",
	"settings",
	"units",
	"map_state",
	"resume_scene",
	"latest_battle_result",
	"latest_battle_map_id",
	"latest_battle_turns",
]

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(slot: int, reason: String)

func has_any_save() -> bool:
	for i in range(1, MAX_SLOTS + 1):
		if FileAccess.file_exists(_get_save_path(i)):
			return true
	return false

func save_game(slot: int, runtime_snapshot: Dictionary = {}) -> bool:
	var data := _build_save_data(runtime_snapshot)
	var path := _get_save_path(slot)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		save_failed.emit(slot, "Cannot open file for writing")
		return false
	var json_str := JSON.new().stringify(data, "\t")
	file.store_string(json_str)
	save_completed.emit(slot)
	return true

func load_game(slot: int) -> Dictionary:
	var path := _get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var json_str := file.get_as_text()
	var json := JSON.new()
	if json.parse(json_str) != OK:
		return {}
	var data := json.get_data() as Dictionary
	if _is_loadable_version(data):
		_migrate(data)
		if not _validate_version(data):
			return {}
		GameState.from_dict(data)
		load_completed.emit(slot)
		return data
	return {}

func _build_save_data(runtime_snapshot: Dictionary = {}) -> Dictionary:
	var state_data := GameState.to_dict()
	for key in runtime_snapshot.keys():
		state_data[key] = runtime_snapshot[key]
	state_data["version"] = SAVE_VERSION
	state_data["timestamp"] = Time.get_unix_time_from_system()
	state_data["settings"] = {}
	return state_data

func _get_save_path(slot: int) -> String:
	return "user://save_%02d.save" % slot

func _validate_version(data: Dictionary) -> bool:
	var ver: String = data.get("version", "0.0.0")
	if ver < MIN_SUPPORTED_VERSION:
		return false
	for field_name in REQUIRED_SAVE_FIELDS:
		if not data.has(field_name):
			return false
	return true

func _is_loadable_version(data: Dictionary) -> bool:
	var ver: String = data.get("version", "0.0.0")
	return ver >= MIN_LOADABLE_VERSION

func _migrate(data: Dictionary) -> void:
	var ver: String = data.get("version", "0.0.0")
	if ver < "2.0.0" and data.has("turn_number") and not data.has("turn"):
		data["turn"] = data["turn_number"]
	if ver < "2.0.0" and not data.has("chapter"):
		data["chapter"] = data.get("map_id", "")
	if ver < "2.0.0" and not data.has("completed_maps"):
		data["completed_maps"] = []
	if not data.has("map_id"):
		data["map_id"] = ""
	if not data.has("turn"):
		data["turn"] = 0
	if not data.has("gold"):
		data["gold"] = 0
	if not data.has("timestamp"):
		data["timestamp"] = Time.get_unix_time_from_system()
	if not data.has("inventory"):
		data["inventory"] = []
	if not data.has("story_flags"):
		data["story_flags"] = {}
	if not data.has("settings"):
		data["settings"] = {}
	if not data.has("units"):
		data["units"] = []
	if not data.has("map_state"):
		data["map_state"] = {}
	if not data.has("latest_battle_result"):
		data["latest_battle_result"] = ""
	if not data.has("latest_battle_map_id"):
		data["latest_battle_map_id"] = data.get("map_id", "")
	if not data.has("latest_battle_turns"):
		data["latest_battle_turns"] = int(data.get("turn", 0))
	if not data.has("resume_scene"):
		if str(data.get("latest_battle_result", "")) != "":
			data["resume_scene"] = "result"
		elif str(data.get("map_id", "")) != "":
			data["resume_scene"] = "battle"
		else:
			data["resume_scene"] = "main_menu"
	data["version"] = SAVE_VERSION
