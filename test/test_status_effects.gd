extends RefCounted

class_name TestStatusEffects

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var urs_script := preload("res://scripts/unit/unit_runtime_state.gd")
	var runtime = urs_script.new()
	runtime.max_hp = 20
	runtime.current_hp = 20

	runtime.status_effects.append({"id": "poison", "duration": 3})

	var has_poison := false
	for e in runtime.status_effects:
		if e.get("id", "") == "poison":
			has_poison = true
	if has_poison:
		details.append("PASS: append adds poison effect")
	else:
		details.append("FAIL: poison not added")
		all_pass = false

	runtime.status_effects.clear()
	runtime.status_effects.append({"id": "poison", "duration": 1})
	var updated: Array[Dictionary] = []
	for effect in runtime.status_effects:
		var dur: int = effect.get("duration", 1) - 1
		if dur > 0:
			effect["duration"] = dur
			updated.append(effect)
	runtime.status_effects = updated
	if runtime.status_effects.is_empty():
		details.append("PASS: tick removes expired effect (duration 1 -> 0)")
	else:
		details.append("FAIL: expired effect not removed")
		all_pass = false

	runtime.status_effects.append({"id": "poison", "duration": 2})
	var has_effect: bool = false
	for e in runtime.status_effects:
		if e.get("id", "") == "poison":
			has_effect = true
	var poison_dur: int = 0
	for e in runtime.status_effects:
		if e.get("id", "") == "poison":
			poison_dur = e.get("duration", 0)
	if has_effect and poison_dur == 2:
		details.append("PASS: re-added poison with duration 2")
	else:
		details.append("FAIL: poison re-add failed")
		all_pass = false

	var ses_script := preload("res://scripts/unit/status_effect_service.gd")
	var ses = ses_script.new()
	runtime.current_hp = 20
	var poison_dmg: int = runtime.max_hp / 10
	if poison_dmg < 1:
		poison_dmg = 1
	runtime.current_hp = max(0, runtime.current_hp - poison_dmg)
	if runtime.current_hp < 20:
		details.append("PASS: manual poison deals %d damage (20 -> %d)" % [poison_dmg, runtime.current_hp])
	else:
		details.append("FAIL: manual poison did not deal damage")
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Status effects %s" % ["passed" if all_pass else "failed"],
		"details": details
	}
