extends RefCounted

class_name TestBattleSkillService

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var service = preload("res://scripts/battle/battle_skill_service.gd").new()
	var unit_scene := preload("res://scenes/battle/unit/unit.tscn")

	var healer = unit_scene.instantiate()
	healer.setup("hero_002", "player", Vector2i(0, 0))
	var ally = unit_scene.instantiate()
	ally.setup("hero_001", "player", Vector2i(1, 0))
	var enemy = unit_scene.instantiate()
	enemy.setup("enemy_001", "enemy", Vector2i(2, 0))

	ally.take_damage(5)
	var heal_result: Dictionary = service.execute_skill(healer, ally, "heal_light")
	if heal_result.get("success", false) and ally.get_current_hp() > 0 and healer.runtime_state.skill_cooldowns.get("heal_light", -1) == 1:
		details.append("PASS: heal skill executes through unified service and writes cooldown")
	else:
		details.append("FAIL: heal skill execution did not produce expected result")
		all_pass = false

	var target_group: String = service.get_target_group("flame_burst")
	if target_group == "enemy":
		details.append("PASS: damage skill target group resolves to enemy")
	else:
		details.append("FAIL: flame_burst target group should be enemy")
		all_pass = false

	var before_hp: int = enemy.get_current_hp()
	var damage_result: Dictionary = service.execute_skill(healer, enemy, "flame_burst")
	if damage_result.get("success", false) and enemy.get_current_hp() < before_hp:
		details.append("PASS: damage skill executes through unified service")
	else:
		details.append("FAIL: damage skill execution did not lower enemy HP")
		all_pass = false

	healer.free()
	ally.free()
	enemy.free()

	var self_unit = unit_scene.instantiate()
	self_unit.setup("hero_001", "player", Vector2i(5, 0))
	var str_before: int = self_unit.runtime_state.str_stat
	var passive_result: Dictionary = service.apply_passive_skill(self_unit, "sword_adept")
	if passive_result.get("success", false) and self_unit.runtime_state.str_stat > str_before:
		details.append("PASS: passive self-buff sword_adept increases STR from %d to %d" % [str_before, self_unit.runtime_state.str_stat])
	else:
		details.append("FAIL: passive self-buff did not increase STR (before=%d after=%d result=%s)" % [str_before, self_unit.runtime_state.str_stat, passive_result])
		all_pass = false
	service.clear_temporary_passives(self_unit)
	if self_unit.runtime_state.str_stat == str_before:
		details.append("PASS: temporary passive buff is cleared after combat cleanup")
	else:
		details.append("FAIL: temporary passive buff should be reverted after cleanup")
		all_pass = false
	self_unit.free()

	var full_hp = unit_scene.instantiate()
	full_hp.setup("hero_001", "player", Vector2i(6, 0))
	full_hp.runtime_state.current_hp = full_hp.runtime_state.max_hp
	var healer2 = unit_scene.instantiate()
	healer2.setup("hero_002", "player", Vector2i(7, 0))
	var full_heal: Dictionary = service.execute_skill(healer2, full_hp, "heal_light")
	if not full_heal.get("success", false):
		details.append("PASS: heal on full HP target returns false")
	else:
		details.append("FAIL: heal on full HP should return false")
		all_pass = false
	full_hp.free()
	healer2.free()

	var enemy_heal: Dictionary = service.execute_skill(healer, enemy, "heal_light")
	if not enemy_heal.get("success", false):
		details.append("PASS: heal on enemy returns false")
	else:
		details.append("FAIL: heal on enemy should return false")
		all_pass = false

	var ally_damage: Dictionary = service.execute_skill(healer, ally, "flame_burst")
	if not ally_damage.get("success", false):
		details.append("PASS: damage on ally returns false")
	else:
		details.append("FAIL: damage on ally should return false")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Battle skill service %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
