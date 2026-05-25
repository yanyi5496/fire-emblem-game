extends Node

var _units: Dictionary = {}
var _weapons: Dictionary = {}
var _jobs: Dictionary = {}
var _skills: Dictionary = {}
var _maps: Dictionary = {}
var _characters: Dictionary = {}

var _schema_validators: Dictionary = {}

func _ready() -> void:
	_register_schemas()
	load_all()

func _register_schemas() -> void:
	_schema_validators["units"] = {
		"required_fields": ["id", "name", "job", "stats", "inventory"],
		"stats_fields": ["hp", "str", "mag", "skl", "spd", "def", "res", "luk", "mov"],
		"known_fields": ["id", "name", "job", "level", "exp", "stats", "growth_rates", "inventory", "skills", "ai_type"],
	}
	_schema_validators["weapons"] = {
		"required_fields": ["id", "type", "might", "hit", "weight", "min_range", "max_range", "durability"],
		"known_fields": ["id", "name", "type", "might", "hit", "crit", "weight", "min_range", "max_range", "durability", "effective_tags", "is_magic"],
	}
	_schema_validators["jobs"] = {
		"required_fields": ["id", "name", "weapons", "mov"],
		"known_fields": ["id", "name", "tier", "promotes_to", "weapons", "mov", "growth_bonus", "terrain_adaptation", "skills"],
	}
	_schema_validators["skills"] = {
		"required_fields": ["id", "type", "trigger", "effect"],
		"known_fields": ["id", "name", "type", "trigger", "cost", "effect", "range", "cooldown", "description", "priority"],
	}
	_schema_validators["maps"] = {
		"required_fields": ["id", "name", "tiles", "terrain_defs", "units"],
		"known_fields": ["id", "name", "width", "height", "tiles", "terrain_ids", "terrain_defs", "units", "victory_condition", "defeat_condition", "max_turns", "lord_unit_id", "capture_points", "escape_points", "escape_type"],
	}
	_schema_validators["characters"] = {
		"required_fields": ["id", "name", "unit_id"],
		"known_fields": ["id", "name", "unit_id", "is_recruited", "story_flags"],
	}

func load_all() -> void:
	_load_directory("units", _units)
	_load_directory("weapons", _weapons)
	_load_directory("jobs", _jobs)
	_load_directory("skills", _skills)
	_load_directory("maps", _maps)
	_load_directory("characters", _characters)

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
			var known: Array = validator.get("known_fields", [])
			for key in item.keys():
				if key not in known:
					errors.append("%s/%s unknown field: %s" % [dir_name, item_id, key])
	_validate_references(errors)
	return { "valid": errors.is_empty(), "errors": errors }

func _validate_references(errors: Array[String]) -> void:
	for uid in _units:
		var u: Dictionary = _units[uid]
		var job_id: String = u.get("job", "")
		if job_id != "" and not _jobs.has(job_id):
			errors.append("units/%s references unknown job: %s" % [uid, job_id])
		for wid in u.get("inventory", []):
			if wid != "" and not _weapons.has(wid):
				errors.append("units/%s references unknown weapon: %s" % [uid, wid])
		for sid in u.get("skills", []):
			if sid != "" and not _skills.has(sid):
				errors.append("units/%s references unknown skill: %s" % [uid, sid])
	for jid in _jobs:
		var j: Dictionary = _jobs[jid]
		for wid in j.get("weapons", []):
			if wid != "" and not _weapons.has(wid):
				errors.append("jobs/%s references unknown weapon: %s" % [jid, wid])
	for mid in _maps:
		var m: Dictionary = _maps[mid]
		for entry in m.get("units", []):
			var unit_id: String = str(entry.get("unit_id", ""))
			if unit_id != "" and not _units.has(unit_id):
				errors.append("maps/%s references unknown unit: %s" % [mid, unit_id])

func _get_data_map(dir_name: String) -> Dictionary:
	match dir_name:
		"units": return _units
		"weapons": return _weapons
		"jobs": return _jobs
		"skills": return _skills
		"maps": return _maps
		"characters": return _characters
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

func get_character(id: String) -> Dictionary:
	return _characters.get(id, {})
