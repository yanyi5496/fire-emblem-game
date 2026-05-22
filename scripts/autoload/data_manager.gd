extends Node

var _units: Dictionary = {}
var _weapons: Dictionary = {}
var _jobs: Dictionary = {}
var _skills: Dictionary = {}
var _maps: Dictionary = {}

var _schema_validators: Dictionary = {}

func _ready() -> void:
	_register_schemas()
	load_all()

func _register_schemas() -> void:
	_schema_validators["units"] = {
		"required_fields": ["id", "name", "job", "stats", "inventory"],
		"stats_fields": ["hp", "str", "mag", "skl", "spd", "def", "res", "luk", "mov"],
	}
	_schema_validators["weapons"] = {
		"required_fields": ["id", "type", "might", "hit", "weight", "min_range", "max_range", "durability"],
	}
	_schema_validators["jobs"] = {
		"required_fields": ["id", "name", "weapons", "mov"],
	}
	_schema_validators["skills"] = {
		"required_fields": ["id", "type", "trigger", "effect"],
	}
	_schema_validators["maps"] = {
		"required_fields": ["id", "name", "tiles", "terrain_defs", "units"],
	}

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
		push_warning("Data directory not found: %s" % path)
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			var file_path := path.path_join(file_name)
			var file := FileAccess.open(file_path, FileAccess.READ)
			if file:
				var json_str := file.get_as_text()
				var json_parser := JSON.new()
				var parse_result := json_parser.parse(json_str)
				if parse_result == OK:
					var data := json_parser.get_data() as Dictionary
					if data.has("id"):
						target[data["id"]] = data
					else:
						push_error("Missing 'id' in %s" % file_path)
				else:
					push_error("JSON parse error in %s: %s" % [file_path, json_parser.get_error_message()])
		file_name = dir.get_next()

func validate_all() -> Dictionary:
	var errors: Array[String] = []
	for dir_name in _schema_validators:
		var validator: Dictionary = _schema_validators[dir_name]
		var data_map: Dictionary = _get_data_map(dir_name)
		for item_id in data_map:
			var item: Dictionary = data_map[item_id] as Dictionary
			for field in validator.get("required_fields", []):
				if not item.has(field):
					errors.append("%s/%s missing field: %s" % [dir_name, item_id, field])
			if item.has("stats") and validator.has("stats_fields"):
				for sfield in validator["stats_fields"]:
					if not item["stats"].has(sfield):
						errors.append("%s/%s.stats missing field: %s" % [dir_name, item_id, sfield])
	return { "valid": errors.is_empty(), "errors": errors }

func _get_data_map(dir_name: String) -> Dictionary:
	match dir_name:
		"units": return _units
		"weapons": return _weapons
		"jobs": return _jobs
		"skills": return _skills
		"maps": return _maps
	return {}

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
