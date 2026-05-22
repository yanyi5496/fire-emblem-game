extends Node

var _units := {}
var _weapons := {}
var _jobs := {}
var _skills := {}
var _maps := {}

func _ready() -> void:
	load_all()

func load_all() -> void:
	_load_directory("units", _units)
	_load_directory("weapons", _weapons)
	_load_directory("jobs", _jobs)
	_load_directory("skills", _skills)
	_load_directory("maps", _maps)

func _load_directory(dir_name: String, target: Dictionary) -> void:
	var path := "res://data/%s/" % dir_name
	var dir := DirAccess.open(path)
	if not dir:
		push_warning("Data directory not found: ", path)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file_path := path.path_join(file_name)
			var file := FileAccess.open(file_path, FileAccess.READ)
			if file:
				var json_str := file.get_as_text()
				var json := JSON.new()
				var parse_result := json.parse(json_str)
				if parse_result == OK:
					var data := json.get_data() as Dictionary
					if data.has("id"):
						target[data["id"]] = data
					else:
						push_error("Missing 'id' in ", file_path)
				else:
					push_error("JSON parse error in ", file_path, ": ", json.get_error_message())
		file_name = dir.get_next()

func reload() -> void:
	_units.clear()
	_weapons.clear()
	_jobs.clear()
	_skills.clear()
	_maps.clear()
	load_all()

func get_unit(id: String) -> Dictionary:
	return _units.get(id, {})

func get_weapon(id: String) -> Dictionary:
	return _weapons.get(id, {})

func get_job(id: String) -> Dictionary:
	return _jobs.get(id, {})

func get_skill(id: String) -> Dictionary:
	return _skills.get(id, {})

func get_map(id: String) -> Dictionary:
	return _maps.get(id, {})

func get_all_units() -> Dictionary:
	return _units.duplicate()

func get_all_weapons() -> Dictionary:
	return _weapons.duplicate()

func get_all_jobs() -> Dictionary:
	return _jobs.duplicate()

func get_all_skills() -> Dictionary:
	return _skills.duplicate()

func get_all_maps() -> Dictionary:
	return _maps.duplicate()
