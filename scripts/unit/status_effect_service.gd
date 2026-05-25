extends Node

class_name StatusEffectService

const _unit_actor_dep := preload("res://scripts/unit/unit_actor.gd")

enum EffectType { POISON, SLEEP, PARALYSIS, SILENCE }

func add_effect(unit, effect_type: String, duration: int) -> void:
	if not unit.runtime_state:
		return
	var effects: Array[Dictionary] = unit.runtime_state.status_effects
	if _is_control_type(effect_type):
		effects = _replace_control_effect(effects, effect_type, duration)
	else:
		effects = _refresh_or_add(effects, effect_type, duration)
	unit.runtime_state.status_effects = effects

func remove_effect(unit, effect_type: String) -> void:
	if not unit.runtime_state:
		return
	unit.runtime_state.status_effects = unit.runtime_state.status_effects.filter(
		func(e): return e.get("id", "") != effect_type
	)

func tick_all(units: Array) -> void:
	for unit in units:
		if not unit.is_alive():
			continue
		tick_effect_durations(unit)

func tick_effect_durations(unit) -> void:
	if not unit.runtime_state:
		return
	var effects: Array[Dictionary] = unit.runtime_state.status_effects
	var updated: Array[Dictionary] = []
	for effect in effects:
		var dur: int = effect.get("duration", 1) - 1
		if dur > 0:
			effect["duration"] = dur
			updated.append(effect)
		else:
			_revert_expired_buff(unit, effect)
	unit.runtime_state.status_effects = updated

func _revert_expired_buff(unit, effect: Dictionary) -> void:
	var effect_id: String = effect.get("id", "")
	if not effect_id.begins_with("stat_buff_"):
		return
	var stat_name: String = effect.get("stat", "")
	var value: int = int(effect.get("value", 0))
	match stat_name:
		"str": unit.runtime_state.str_stat = max(0, unit.runtime_state.str_stat - value)
		"mag": unit.runtime_state.mag_stat = max(0, unit.runtime_state.mag_stat - value)
		"def": unit.runtime_state.def_stat = max(0, unit.runtime_state.def_stat - value)
		"res": unit.runtime_state.res_stat = max(0, unit.runtime_state.res_stat - value)
		"spd": unit.runtime_state.spd_stat = max(0, unit.runtime_state.spd_stat - value)
		"skl": unit.runtime_state.skl_stat = max(0, unit.runtime_state.skl_stat - value)
		"luk": unit.runtime_state.luk_stat = max(0, unit.runtime_state.luk_stat - value)

func has_effect(unit, effect_type: String) -> bool:
	if not unit.runtime_state:
		return false
	for e in unit.runtime_state.status_effects:
		if e.get("id", "") == effect_type:
			return true
	return false

func _apply_poison(unit) -> void:
	var dmg: int = max(1, unit.runtime_state.max_hp / 10)
	unit.take_damage(dmg)

func apply_poison_tick(unit) -> void:
	if has_effect(unit, "poison"):
		_apply_poison(unit)

func _is_control_type(type: String) -> bool:
	return type in ["sleep", "paralysis"]

func _replace_control_effect(effects: Array[Dictionary], type: String, duration: int) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for e in effects:
		if e.get("id", "") not in ["sleep", "paralysis"]:
			filtered.append(e)
	filtered.append({ "id": type, "duration": duration })
	return filtered

func _refresh_or_add(effects: Array[Dictionary], type: String, duration: int) -> Array[Dictionary]:
	for e in effects:
		if e.get("id", "") == type:
			e["duration"] = duration
			return effects
	effects.append({ "id": type, "duration": duration })
	return effects
