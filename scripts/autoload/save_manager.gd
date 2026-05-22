extends Node

class_name SaveManager

const SAVE_VERSION := "2.0.0"
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
]

signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(slot: int, reason: String)

func save_game(slot: int) -> bool:
	var data := _build_save_data()
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
	if _validate_version(data):
		GameState.from_dict(data)
		load_completed.emit(slot)
		return data
	return {}

func _build_save_data() -> Dictionary:
	var state_data := GameState.to_dict()
	state_data["version"] = SAVE_VERSION
	state_data["timestamp"] = Time.get_unix_time_from_system()
	state_data["settings"] = {}
	return state_data

func _get_save_path(slot: int) -> String:
	return "user://save_%02d.save" % slot

func _validate_version(data: Dictionary) -> bool:
	if data.get("version", "") != SAVE_VERSION:
		return false
	for field_name in REQUIRED_SAVE_FIELDS:
		if not data.has(field_name):
			return false
	return true
