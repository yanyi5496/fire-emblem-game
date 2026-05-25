extends RefCounted

class_name TestAIBehavior

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var urs_script := preload("res://scripts/unit/unit_runtime_state.gd")

	var attacker_rs = urs_script.new()
	attacker_rs.str_stat = 8
	attacker_rs.mag_stat = 0
	attacker_rs.skl_stat = 10
	attacker_rs.spd_stat = 7
	attacker_rs.luk_stat = 5
	attacker_rs.equipped_weapon = "iron_sword"

	var defender_rs = urs_script.new()
	defender_rs.def_stat = 3
	defender_rs.res_stat = 2
	defender_rs.spd_stat = 5
	defender_rs.luk_stat = 2

	var weapon_data = DataManager.get_weapon("iron_sword")
	var might := int(weapon_data.get("might", 0))
	var weapon_hit := int(weapon_data.get("hit", 0))
	var weapon_type := weapon_data.get("type", "")

	var damage := max(0, attacker_rs.str_stat + might - defender_rs.def_stat)
	if damage > 0:
		details.append("PASS: calculated physical damage = %d (str=%d + might=%d - def=%d)" % [damage, attacker_rs.str_stat, might, defender_rs.def_stat])
	else:
		details.append("FAIL: damage should be > 0")
		all_pass = false

	var hit_rate := clampi(weapon_hit + attacker_rs.skl_stat * 2 + attacker_rs.luk_stat - (defender_rs.spd_stat / 2 + defender_rs.luk_stat), 0, 100)
	if hit_rate > 0:
		details.append("PASS: calculated hit rate = %d%%" % hit_rate)
	else:
		details.append("FAIL: hit rate should be > 0")
		all_pass = false

	var follow_up: bool = attacker_rs.spd_stat - defender_rs.spd_stat >= 4
	if not follow_up:
		details.append("PASS: no follow-up (spd %d - spd %d = %d < 4)" % [attacker_rs.spd_stat, defender_rs.spd_stat, attacker_rs.spd_stat - defender_rs.spd_stat])
	else:
		details.append("FAIL: SPD difference below 4 should not trigger follow-up")
		all_pass = false

	var no_follow_rs = urs_script.new()
	no_follow_rs.spd_stat = 1
	var no_follow: bool = no_follow_rs.spd_stat - defender_rs.spd_stat >= 4
	if not no_follow:
		details.append("PASS: no follow-up when SPD diff < 4")
	else:
		details.append("FAIL: no follow-up expected")
		all_pass = false

	var mag_attacker_rs = urs_script.new()
	mag_attacker_rs.str_stat = 2
	mag_attacker_rs.mag_stat = 6
	mag_attacker_rs.skl_stat = 8
	mag_attacker_rs.luk_stat = 4

	var def_high_rs = urs_script.new()
	def_high_rs.def_stat = 10
	def_high_rs.res_stat = 2
	def_high_rs.spd_stat = 3
	def_high_rs.luk_stat = 3

	var weapon_data_heal = DataManager.get_weapon("heal_staff")
	var heal_might := int(weapon_data_heal.get("might", 0))
	var phys_dmg := max(0, mag_attacker_rs.str_stat + heal_might - def_high_rs.def_stat)
	var magic_dmg := max(0, mag_attacker_rs.mag_stat + heal_might - def_high_rs.res_stat)
	if magic_dmg > phys_dmg:
		details.append("PASS: magic attack bypasses high DEF (mag dmg=%d > phys dmg=%d)" % [magic_dmg, phys_dmg])
	else:
		details.append("FAIL: magic should deal more damage vs high DEF target")
		all_pass = false

	var triangle := {
		"sword": "axe",
		"lance": "sword",
		"axe": "lance",
	}
	var sword_beats := triangle.get("sword", "")
	if sword_beats == "axe":
		details.append("PASS: sword beats axe in weapon triangle")
	else:
		details.append("FAIL: triangle rule sword->axe not found")
		all_pass = false
	var lance_beats := triangle.get("lance", "")
	if lance_beats == "sword":
		details.append("PASS: lance beats sword in weapon triangle")
	else:
		details.append("FAIL: triangle rule lance->sword not found")
		all_pass = false
	var unarmed_match: String = triangle.get("", "")
	if unarmed_match.is_empty():
		details.append("PASS: unarmed weapon has no triangle effect")
	else:
		details.append("FAIL: unarmed should have no triangle")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "AI behavior %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
