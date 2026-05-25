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

	var ai := preload("res://scripts/battle/ai_controller.gd").new()
	var unit_scene := preload("res://scenes/battle/unit/unit.tscn")

	var mock_attacker = unit_scene.instantiate()
	mock_attacker.setup("enemy_001", "enemy", Vector2i(0, 0))
	mock_attacker.runtime_state.str_stat = 12
	mock_attacker.runtime_state.equipped_weapon = "iron_sword"

	var mock_low_target = unit_scene.instantiate()
	mock_low_target.setup("hero_001", "player", Vector2i(1, 0))
	mock_low_target.runtime_state.current_hp = 3
	mock_low_target.runtime_state.def_stat = 0

	var mock_full_target = unit_scene.instantiate()
	mock_full_target.setup("hero_002", "player", Vector2i(2, 0))
	mock_full_target.runtime_state.def_stat = 10

	var low_score := ai._evaluate_attack(mock_attacker, mock_low_target)
	var high_score := ai._evaluate_attack(mock_attacker, mock_full_target)
	if low_score > high_score:
		details.append("PASS: AI prioritizes low-HP target over full-HP (score %d > %d)" % [low_score, high_score])
	else:
		details.append("FAIL: low-HP target should score higher (got %d vs %d)" % [low_score, high_score])
		all_pass = false

	var mock_healer = unit_scene.instantiate()
	mock_healer.setup("hero_002", "player", Vector2i(3, 0))
	mock_healer.runtime_state.def_stat = 5
	mock_healer.runtime_state.skills.append("heal_light")

	var mock_normal = unit_scene.instantiate()
	mock_normal.setup("hero_001", "player", Vector2i(4, 0))
	mock_normal.runtime_state.def_stat = 5

	var healer_atk_score := ai._evaluate_attack(mock_attacker, mock_healer)
	var normal_atk_score := ai._evaluate_attack(mock_attacker, mock_normal)
	if healer_atk_score > normal_atk_score:
		details.append("PASS: AI prioritizes healer over normal target (score %d > %d)" % [healer_atk_score, normal_atk_score])
	else:
		details.append("FAIL: healer should score higher than normal target")
		all_pass = false

	var skill_service = preload("res://scripts/battle/battle_skill_service.gd").new()
	var self_buff_skill := ai._evaluate_self_buff(mock_attacker)
	if self_buff_skill == "":
		details.append("PASS: unit without self buff does not pick one")
	else:
		details.append("FAIL: unit without self buff should not pick self buff")
		all_pass = false

	var buff_unit = unit_scene.instantiate()
	buff_unit.setup("hero_001", "enemy", Vector2i(5, 0))
	var buff_before: int = buff_unit.runtime_state.str_stat
	var self_buff_result: bool = ai._execute_self_buff_action(buff_unit, "power_strike", skill_service)
	if self_buff_result and buff_unit.runtime_state.str_stat > buff_before:
		details.append("PASS: AI self_buff action executes through shared skill_service")
	else:
		details.append("FAIL: AI self_buff action should increase stat via skill_service")
		all_pass = false

	buff_unit.free()

	mock_attacker.free()
	mock_low_target.free()
	mock_full_target.free()
	mock_healer.free()
	mock_normal.free()

	return {
		"passed": all_pass,
		"message": "AI behavior %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
