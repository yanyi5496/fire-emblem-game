extends RefCounted

class_name TestDataSchema

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var dm := DataManager.new()
	dm.load_all()

	# Check units
	var unit_ids := ["hero_001", "hero_002", "enemy_001", "enemy_002"]
	var unit_fields := ["id", "name", "job", "stats", "inventory"]
	for uid in unit_ids:
		var u := dm.get_unit(uid)
		if u.is_empty():
			details.append("MISSING unit: %s" % uid)
			all_pass = false
			continue
		for f in unit_fields:
			if not u.has(f):
				details.append("unit %s missing field: %s" % [uid, f])
				all_pass = false
		if u.has("stats"):
			for s in ["hp", "str", "mag", "skl", "spd", "def", "res", "luk", "mov"]:
				if not u["stats"].has(s):
					details.append("unit %s.stats missing: %s" % [uid, s])
					all_pass = false

	# Check weapons
	var weapon_ids := ["iron_sword", "iron_axe", "heal_staff"]
	var weapon_fields := ["id", "type", "might", "hit", "weight", "min_range", "max_range", "durability"]
	for wid in weapon_ids:
		var w := dm.get_weapon(wid)
		if w.is_empty():
			details.append("MISSING weapon: %s" % wid)
			all_pass = false
			continue
		for f in weapon_fields:
			if not w.has(f):
				details.append("weapon %s missing field: %s" % [wid, f])
				all_pass = false

	# Check jobs
	var job_ids := ["swordman", "axefighter", "priest"]
	for jid in job_ids:
		var j := dm.get_job(jid)
		if j.is_empty():
			details.append("MISSING job: %s" % jid)
			all_pass = false
			continue
		if not j.has("weapons") or not j.has("mov"):
			details.append("job %s missing weapons or mov" % jid)
			all_pass = false

	# Check skills
	var skill_ids := ["sword_adept", "heal_light", "tough_body"]
	for sid in skill_ids:
		var s := dm.get_skill(sid)
		if s.is_empty():
			details.append("MISSING skill: %s" % sid)
			all_pass = false
			continue
		if not s.has("type") or not s.has("trigger") or not s.has("effect"):
			details.append("skill %s missing type/trigger/effect" % sid)
			all_pass = false

	# Check map
	var map_data := dm.get_map("mvp_map_01")
	if map_data.is_empty():
		details.append("MISSING map: mvp_map_01")
		all_pass = false
	else:
		if not map_data.has("tiles") or not map_data.has("terrain_defs"):
			details.append("map missing tiles or terrain_defs")
			all_pass = false
		if map_data.has("units"):
			for u in map_data["units"]:
				if not u.has("unit_id") or not u.has("x") or not u.has("y") or not u.has("team"):
					details.append("map unit entry incomplete")
					all_pass = false

	# Cross-reference integrity
	for uid in unit_ids:
		var u := dm.get_unit(uid)
		if u.is_empty():
			continue
		var job_id := u.get("job", "")
		if job_id != "" and dm.get_job(job_id).is_empty():
			details.append("unit %s references missing job: %s" % [uid, job_id])
			all_pass = false
		for inv_id in u.get("inventory", []):
			if dm.get_weapon(inv_id).is_empty():
				details.append("unit %s references missing weapon: %s" % [uid, inv_id])
				all_pass = false

	dm.free()
	return {
		"passed": all_pass,
		"message": "Data schema validation %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
