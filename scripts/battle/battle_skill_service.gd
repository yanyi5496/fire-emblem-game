extends RefCounted

class_name BattleSkillService

func get_available_skills(unit) -> Array[String]:
	var available: Array[String] = []
	if not unit or not unit.runtime_state:
		return available
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") != "active":
			continue
		if not unit.runtime_state.can_use_skill(skill_id):
			continue
		available.append(skill_id)
	return available

func get_skill_range(unit, skill_id: String) -> Vector2i:
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	if skill_data.has("range"):
		return Vector2i(int(skill_data["range"].get("min", 1)), int(skill_data["range"].get("max", 1)))
	var weapon_data: Dictionary = DataManager.get_weapon(unit.runtime_state.equipped_weapon)
	return Vector2i(int(weapon_data.get("min_range", 1)), int(weapon_data.get("max_range", 1)))

func get_target_group(skill_id: String) -> String:
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	var effect: Dictionary = skill_data.get("effect", {})
	var explicit_target: String = str(effect.get("target", ""))
	if explicit_target != "":
		return explicit_target
	match str(effect.get("type", "")):
		"heal":
			return "ally"
		"damage":
			return "enemy"
		"stat_bonus":
			return "self"
		_:
			return ""

func get_skill_targets(unit, skill_id: String, battle_query: Node, pathfinding: Node, tile_map: TileMap) -> Array:
	var result: Array = []
	if not unit or not unit.runtime_state or not battle_query or not pathfinding or not tile_map:
		return result
	var target_group: String = get_target_group(skill_id)
	if target_group == "self":
		result.append(unit)
		return result
	var skill_range: Vector2i = get_skill_range(unit, skill_id)
	var tiles: Array[Vector2i] = pathfinding.get_attack_range(unit.grid_pos, skill_range.x, skill_range.y, tile_map)
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	var effect_type: String = skill_data.get("effect", {}).get("type", "")
	for tile in tiles:
		var target = battle_query.get_unit_at(tile)
		if not target or not target.is_alive():
			continue
		if target_group == "ally" and target.team == unit.team:
			if effect_type == "heal" and target.get_current_hp() >= target.get_max_hp():
				continue
			result.append(target)
		elif target_group == "enemy" and target.team != unit.team:
			result.append(target)
	return result

func get_target_tiles(unit, skill_id: String, battle_query: Node, pathfinding: Node, tile_map: TileMap) -> Array[Vector2i]:
	var tiles: Array[Vector2i] = []
	for target in get_skill_targets(unit, skill_id, battle_query, pathfinding, tile_map):
		tiles.append(target.grid_pos)
	return tiles

func execute_skill(unit, target, skill_id: String) -> Dictionary:
	if not unit or not unit.runtime_state or skill_id == "":
		return {"success": false, "message": ""}
	var skill_data: Dictionary = DataManager.get_skill(skill_id)
	var effect: Dictionary = skill_data.get("effect", {})
	var effect_type: String = str(effect.get("type", ""))
	match effect_type:
		"heal":
			return _execute_heal(unit, target, skill_id, effect)
		"damage":
			return _execute_damage(unit, target, skill_id, effect)
		"stat_bonus":
			return _execute_stat_bonus(unit, target if target else unit, skill_id, skill_data, effect)
		_:
			return {"success": false, "message": ""}

func _execute_heal(unit, target, skill_id: String, effect: Dictionary) -> Dictionary:
	if not target or target.team != unit.team:
		return {"success": false, "message": ""}
	if target.get_current_hp() >= target.get_max_hp():
		return {"success": false, "message": ""}
	var effect_value: int = int(effect.get("value", 0))
	target.heal(effect_value)
	unit.runtime_state.trigger_skill_cooldown(skill_id)
	unit.wait()
	return {
		"success": true,
		"action": "skill",
		"message": "%s 为 %s 恢复了 %d HP" % [unit.unit_id, target.unit_id, effect_value],
	}

func _execute_damage(unit, target, skill_id: String, effect: Dictionary) -> Dictionary:
	if not target or target.team == unit.team:
		return {"success": false, "message": ""}
	unit.attack(target)
	var attack_stat: String = str(effect.get("stat", "str"))
	var effect_value: int = int(effect.get("value", 0))
	var raw_damage: int = effect_value
	if attack_stat == "mag":
		raw_damage += unit.runtime_state.mag_stat
	else:
		raw_damage += unit.runtime_state.str_stat
	var defense_value: int = target.runtime_state.def_stat
	if bool(effect.get("magic", false)):
		defense_value = target.runtime_state.res_stat
	var final_damage: int = max(0, raw_damage - defense_value / 2)
	target.take_damage(final_damage)
	unit.runtime_state.trigger_skill_cooldown(skill_id)
	unit.wait()
	return {
		"success": true,
		"action": "skill",
		"message": "%s 对 %s 造成了 %d 点伤害" % [unit.unit_id, target.unit_id, final_damage],
		"damage": final_damage,
	}

func _execute_stat_bonus(unit, target, skill_id: String, skill_data: Dictionary, effect: Dictionary) -> Dictionary:
	if not target or not target.runtime_state:
		return {"success": false, "message": ""}
	var stat_name: String = str(effect.get("stat", ""))
	var bonus: int = int(effect.get("value", 0))
	var duration: int = int(effect.get("duration", 1))
	match stat_name:
		"str": target.runtime_state.str_stat += bonus
		"mag": target.runtime_state.mag_stat += bonus
		"def": target.runtime_state.def_stat += bonus
		"res": target.runtime_state.res_stat += bonus
		"spd": target.runtime_state.spd_stat += bonus
		"skl": target.runtime_state.skl_stat += bonus
		"luk": target.runtime_state.luk_stat += bonus
		_:
			return {"success": false, "message": ""}
	var buff_effect: Dictionary = {
		"id": "stat_buff_%s" % stat_name,
		"duration": duration,
		"stat": stat_name,
		"value": bonus,
	}
	target.runtime_state.status_effects.append(buff_effect)
	unit.runtime_state.trigger_skill_cooldown(skill_id)
	unit.wait()
	return {
		"success": true,
		"action": "skill",
		"message": "%s 使用了 %s" % [unit.unit_id, skill_data.get("name", skill_id)],
	}
