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

	return {
		"passed": all_pass,
		"message": "Battle skill service %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
