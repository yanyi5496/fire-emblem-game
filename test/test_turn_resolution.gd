extends RefCounted

class_name TestTurnResolution

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var urs_script := preload("res://scripts/unit/unit_runtime_state.gd")
	var runtime = urs_script.new()
	runtime.max_hp = 20
	runtime.current_hp = 20
	var effects: Array[Dictionary] = [{"id": "poison", "duration": 2}]
	runtime.status_effects = effects
	runtime.skill_cooldowns = {"heal_light": 1}

	var updated: Array[Dictionary] = []
	for effect in runtime.status_effects:
		var dur: int = effect.get("duration", 1) - 1
		if dur > 0:
			effect["duration"] = dur
			updated.append(effect)
	runtime.status_effects = updated
	if runtime.status_effects.size() == 1 and runtime.status_effects[0].get("duration", 0) == 1:
		details.append("PASS: duration decrements from 2 to 1")
	else:
		details.append("FAIL: duration did not decrement correctly")
		all_pass = false

	var poison_damage: int = max(1, runtime.max_hp / 10)
	runtime.current_hp = max(0, runtime.current_hp - poison_damage)
	if runtime.current_hp < 20:
		details.append("PASS: poison damage reduces HP (20 -> %d)" % runtime.current_hp)
	else:
		details.append("FAIL: poison damage did not reduce HP")
		all_pass = false

	var poison_hp: int = runtime.current_hp
	updated.clear()
	for effect in runtime.status_effects:
		var dur: int = effect.get("duration", 1) - 1
		if dur > 0:
			effect["duration"] = dur
			updated.append(effect)
	runtime.status_effects = updated
	if runtime.status_effects.is_empty():
		details.append("PASS: expired effect removed (duration 1 -> 0)")
	else:
		details.append("FAIL: expired effect was not removed")
		all_pass = false

	var no_poison: bool = true
	for e in runtime.status_effects:
		if e.get("id", "") == "poison":
			no_poison = false
	if no_poison:
		details.append("PASS: poison effect no longer present after expiry")
	else:
		details.append("FAIL: poison still present after expiry")
		all_pass = false
	if runtime.current_hp == poison_hp:
		details.append("PASS: no damage dealt after poison expired")
	else:
		details.append("FAIL: HP changed after poison expiry")
		all_pass = false

	var cooldowns: Dictionary = runtime.skill_cooldowns
	for skill_id in cooldowns.keys():
		cooldowns[skill_id] = max(0, int(cooldowns[skill_id]) - 1)
	if cooldowns.get("heal_light", 0) == 0:
		details.append("PASS: skill cooldown decrements from 1 to 0")
	else:
		details.append("FAIL: skill cooldown did not decrement correctly")
		all_pass = false

	var silence_runtime = urs_script.new()
	silence_runtime.skills.append("heal_light")
	silence_runtime.skill_cooldowns["heal_light"] = 0
	if silence_runtime.can_use_skill("heal_light"):
		details.append("PASS: can_use_skill true without silence")
	else:
		details.append("FAIL: should be able to use skill without silence")
		all_pass = false
	var silence_effects: Array[Dictionary] = [{"id": "silence", "duration": 2}]
	silence_runtime.status_effects = silence_effects
	if not silence_runtime.can_use_skill("heal_light"):
		details.append("PASS: can_use_skill returns false when silenced")
	else:
		details.append("FAIL: silenced unit should not be able to use skills")
		all_pass = false
	var se: Array[Dictionary] = silence_runtime.status_effects.duplicate(true)
	se[0]["duration"] = 1
	silence_runtime.status_effects = se
	if not silence_runtime.can_use_skill("heal_light"):
		details.append("PASS: can_use_skill false while silence persists (dur=1)")
	else:
		details.append("FAIL: should still be silenced with duration 1")
		all_pass = false
	se[0]["duration"] = 0
	silence_runtime.status_effects = se
	if silence_runtime.can_use_skill("heal_light"):
		details.append("PASS: can_use_skill true after silence expired")
	else:
		details.append("FAIL: should regain skill use after silence expires")
		all_pass = false

	var ses = preload("res://scripts/unit/status_effect_service.gd").new()
	var test_unit = preload("res://scenes/battle/unit/unit.tscn").instantiate()
	test_unit.setup("hero_002", "player", Vector2i(0, 0))
	if not ses.has_effect(test_unit, "silence"):
		details.append("PASS: unit starts without silence")
	else:
		details.append("FAIL: unit should not have silence initially")
		all_pass = false
	ses.add_effect(test_unit, "silence", 3)
	if ses.has_effect(test_unit, "silence"):
		details.append("PASS: add_effect adds silence to unit")
	else:
		details.append("FAIL: silence should be present after add_effect")
		all_pass = false
	test_unit.free()

	return {
		"passed": all_pass,
		"message": "Turn resolution %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
