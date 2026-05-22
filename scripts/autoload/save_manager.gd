extends Node

class_name SaveManager

const SAVE_VERSION := "1.0.0"
const MAX_SLOTS := 10
const MAX_AUTO_SAVES := 5

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
		load_completed.emit(slot)
		return data
	return {}

func _build_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"chapter": "",
		"turn_number": 0,
		"units": [],
		"map_state": {},
		"inventory": [],
		"gold": 0,
		"story_flags": {},
		"settings": {}
	}

func _get_save_path(slot: int) -> String:
	return "user://save_%02d.save" % slot

func _validate_version(data: Dictionary) -> bool:
	return data.has("version")
