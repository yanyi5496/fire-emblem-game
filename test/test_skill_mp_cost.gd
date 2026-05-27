extends RefCounted

class_name TestSkillMpCost

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	DataManager.load_all()

	var urs_script := preload("res://scripts/unit/unit_runtime_state.gd")
	var runtime := urs_script.new()
	runtime.current_mp = 0
	runtime.max_mp = 10
	runtime.skill_cooldowns = {}

	if not runtime.can_use_skill("flame_burst"):
		details.append("PASS: cannot use flame_burst with 0 MP")
	else:
		details.append("FAIL: should reject skill when MP insufficient")
		all_pass = false

	runtime.current_mp = 10
	if runtime.can_use_skill("flame_burst"):
		details.append("PASS: can use flame_burst with 10 MP")
	else:
		details.append("FAIL: should allow skill with enough MP")
		all_pass = false

	runtime.current_mp = 6
	if runtime.can_use_skill("flame_burst"):
		details.append("PASS: can use flame_burst with exactly 6 MP")
	else:
		details.append("FAIL: should allow at exact MP cost")
		all_pass = false

	runtime.current_mp = 5
	if not runtime.can_use_skill("flame_burst"):
		details.append("PASS: cannot use flame_burst with 5 MP (cost=6 from data)")
	else:
		details.append("FAIL: should reject when MP < cost")
		all_pass = false

	runtime.current_mp = 5
	if runtime.can_use_skill("heal_light"):
		details.append("PASS: heal_light with 5 MP usable (cost=4)")
	else:
		details.append("FAIL: skill with 5 MP (>= cost 4) should be usable")
		all_pass = false

	runtime.current_mp = 10
	runtime.consume_skill_cost("flame_burst")
	if runtime.current_mp == 4:
		details.append("PASS: consume_skill_cost deducts correct MP (10-6=4)")
	else:
		details.append("FAIL: MP after consume should be 4, got %d" % runtime.current_mp)
		all_pass = false

	runtime.current_mp = 2
	runtime.consume_skill_cost("flame_burst")
	if runtime.current_mp == 0:
		details.append("PASS: consume_skill_cost floors at 0")
	else:
		details.append("FAIL: MP should be 0, got %d" % runtime.current_mp)
		all_pass = false

	runtime.current_mp = 10
	runtime.consume_skill_cost("heal_light")
	if runtime.current_mp == 6:
		details.append("PASS: consume_skill_cost deducts heal_light MP (10-4=6)")
	else:
		details.append("FAIL: heal_light MP deduction wrong, got %d" % runtime.current_mp)
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Skill MP cost %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
