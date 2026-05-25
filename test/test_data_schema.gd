extends RefCounted

class_name TestDataSchema

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	DataManager.load_all()

	var unit_ids := ["hero_001", "hero_002", "enemy_001", "enemy_002"]
	var unit_fields := ["id", "name", "job", "stats", "inventory"]
	for uid in unit_ids:
		var u = DataManager.get_unit(uid)
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

	var weapon_ids := ["iron_sword", "iron_axe", "heal_staff"]
	var weapon_fields := ["id", "type", "might", "hit", "weight", "min_range", "max_range", "durability"]
	for wid in weapon_ids:
		var w = DataManager.get_weapon(wid)
		if w.is_empty():
			details.append("MISSING weapon: %s" % wid)
			all_pass = false
			continue
		for f in weapon_fields:
			if not w.has(f):
				details.append("weapon %s missing field: %s" % [wid, f])
				all_pass = false

	var job_ids := ["swordman", "axefighter", "priest"]
	for jid in job_ids:
		var j = DataManager.get_job(jid)
		if j.is_empty():
			details.append("MISSING job: %s" % jid)
			all_pass = false
			continue
		if not j.has("weapons") or not j.has("mov"):
			details.append("job %s missing weapons or mov" % jid)
			all_pass = false

	var skill_ids := ["sword_adept", "heal_light", "tough_body", "flame_burst", "power_strike"]
	for sid in skill_ids:
		var s = DataManager.get_skill(sid)
		if s.is_empty():
			details.append("MISSING skill: %s" % sid)
			all_pass = false
			continue
		if not s.has("type") or not s.has("trigger") or not s.has("effect"):
			details.append("skill %s missing type/trigger/effect" % sid)
			all_pass = false

	var map_ids := ["mvp_map_01", "mvp_map_02_defend"]
	for mid in map_ids:
		var map_data = DataManager.get_map(mid)
		if map_data.is_empty():
			details.append("MISSING map: %s" % mid)
			all_pass = false
		else:
			if not map_data.has("tiles") or not map_data.has("terrain_defs"):
				details.append("map %s missing tiles or terrain_defs" % mid)
				all_pass = false
			if not map_data.has("victory_condition") or not map_data.has("defeat_condition"):
				details.append("map %s missing victory_condition or defeat_condition" % mid)
				all_pass = false
			if map_data.has("units"):
				for u in map_data["units"]:
					if not u.has("unit_id") or not u.has("x") or not u.has("y") or not u.has("team"):
						details.append("map %s unit entry incomplete" % mid)
						all_pass = false

	for uid in unit_ids:
		var u = DataManager.get_unit(uid)
		if u.is_empty():
			continue
		var job_id = u.get("job", "")
		if job_id != "" and DataManager.get_job(job_id).is_empty():
			details.append("unit %s references missing job: %s" % [uid, job_id])
			all_pass = false
		for inv_id in u.get("inventory", []):
			if DataManager.get_weapon(inv_id).is_empty():
				details.append("unit %s references missing weapon: %s" % [uid, inv_id])
				all_pass = false
	return {
		"passed": all_pass,
		"message": "Data schema validation %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
