class_name TurnSettlementService

var _status_effect_service = null

func _init() -> void:
	_status_effect_service = StatusEffectService.new()

func process_round_end(units: Array) -> void:
	process_debuff_ticks(units)
	process_poison_damage(units)
	process_auto_heal(units)
	process_skill_cooldowns(units)

func process_debuff_ticks(units: Array) -> void:
	for unit in units:
		if unit.is_alive():
			_status_effect_service.tick_effect_durations(unit)

func process_poison_damage(units: Array) -> void:
	for unit in units:
		if unit.is_alive():
			_status_effect_service.apply_poison_tick(unit)

func process_auto_heal(units: Array) -> void:
	for unit in units:
		if not unit.is_alive():
			continue
		if _has_turn_end_heal(unit):
			unit.heal(2)

func process_skill_cooldowns(units: Array) -> void:
	for unit in units:
		if not unit.is_alive() or not unit.runtime_state:
			continue
		var cooldowns: Dictionary = unit.runtime_state.skill_cooldowns
		for skill_id in cooldowns.keys():
			cooldowns[skill_id] = max(0, int(cooldowns[skill_id]) - 1)
		unit.runtime_state.skill_cooldowns = cooldowns

func process_passive_triggers(units: Array, trigger_type: String, skill_service) -> void:
	if not skill_service:
		return
	for unit in units:
		if unit.is_alive() and unit.runtime_state:
			skill_service.apply_unit_passives(unit, trigger_type)

func reset_action_states(units: Array) -> void:
	for unit in units:
		if unit.is_alive():
			unit.reset_action_state()

func _has_turn_end_heal(unit) -> bool:
	if not unit.runtime_state:
		return false
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("trigger", "") == "turn_end" and skill_data.get("effect", {}).get("type", "") == "heal":
			return true
	return false