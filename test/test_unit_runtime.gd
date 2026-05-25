extends RefCounted

class_name TestUnitRuntime

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var urs_script := preload("res://scripts/unit/unit_runtime_state.gd")
	var runtime = urs_script.new()

	runtime.max_hp = 20
	runtime.current_hp = 20
	runtime.str_stat = 5
	runtime.mag_stat = 3
	runtime.skl_stat = 4
	runtime.spd_stat = 6
	runtime.def_stat = 7
	runtime.res_stat = 8
	runtime.luk_stat = 9
	runtime.mov_stat = 5

	var stats = runtime.get_stats()
	var expected := {"hp": 20, "max_hp": 20, "str": 5, "mag": 3, "skl": 4, "spd": 6, "def": 7, "res": 8, "luk": 9, "mov": 5}
	var stats_ok := true
	for key in expected:
		if stats.get(key, -1) != expected[key]:
			stats_ok = false
			details.append("FAIL: get_stats %s expected %d got %d" % [key, expected[key], stats.get(key, -1)])
	if stats_ok:
		details.append("PASS: get_stats returns correct values")

	runtime.skill_cooldowns = {}
	if runtime.can_use_skill("heal_light"):
		details.append("PASS: can_use_skill true when skill not in cooldowns")
	else:
		details.append("FAIL: can_use_skill should be true for unknown skill")
		all_pass = false

	runtime.skill_cooldowns = {"heal_light": 0}
	if runtime.can_use_skill("heal_light"):
		details.append("PASS: can_use_skill true when cooldown is 0")
	else:
		details.append("FAIL: can_use_skill should be true at 0")
		all_pass = false

	runtime.skill_cooldowns = {"heal_light": 1}
	if not runtime.can_use_skill("heal_light"):
		details.append("PASS: can_use_skill false when cooldown > 0")
	else:
		details.append("FAIL: can_use_skill should be false on cooldown")
		all_pass = false

	runtime.skill_cooldowns = {"heal_light": 0}
	runtime.trigger_skill_cooldown("heal_light")
	if runtime.skill_cooldowns.get("heal_light", 0) > 0:
		details.append("PASS: trigger_skill_cooldown sets cooldown > 0")
	else:
		details.append("FAIL: trigger_skill_cooldown did not set cooldown")
		all_pass = false

	runtime.current_hp = 15
	runtime.current_mp = 5
	var saved_inv: Array[String] = ["iron_sword"]
	var saved_skills: Array[String] = ["sword_adept"]
	var saved_effects: Array[Dictionary] = [{"id": "poison", "duration": 2}]
	var saved_cooldowns: Dictionary = {"heal_light": 1}
	var saved := {
		"current_hp": 8,
		"current_mp": 2,
		"level": 3,
		"exp": 50,
		"inventory": saved_inv,
		"skills": saved_skills,
		"status_effects": saved_effects,
		"skill_cooldowns": saved_cooldowns,
		"equipped_weapon": "iron_sword",
		"action_state": 2,
		"stats": {"max_hp": 20, "max_mp": 10, "str": 6, "mag": 4},
	}
	runtime.apply_saved_state(saved)
	if runtime.current_hp == 8 and runtime.current_mp == 2:
		details.append("PASS: apply_saved_state restores HP/MP")
	else:
		details.append("FAIL: HP/MP restore: %d/%d" % [runtime.current_hp, runtime.current_mp])
		all_pass = false
	if runtime.level == 3 and runtime.exp == 50:
		details.append("PASS: apply_saved_state restores level/exp")
	else:
		details.append("FAIL: level/exp restore")
		all_pass = false
	if runtime.equipped_weapon == "iron_sword" and runtime.action_state == 2:
		details.append("PASS: apply_saved_state restores weapon/action_state")
	else:
		details.append("FAIL: weapon/action_state restore")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Unit runtime %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
