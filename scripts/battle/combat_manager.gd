extends RefCounted

class_name CombatManager

signal combat_started(attacker_id: String, defender_id: String)
signal combat_finished(result: Dictionary)

const WEAPON_TRIANGLE := {
	"sword": "axe",
	"lance": "sword",
	"axe": "lance",
}

var _battle_query: Node = null

func initialize(battle_query: Node) -> void:
	_battle_query = battle_query

func simulate(attacker: Node, defender: Node, weapon_id: String) -> Dictionary:
	var weapon_data: Dictionary = DataManager.get_weapon(weapon_id)
	var result: Dictionary = _create_result(attacker, defender, weapon_id, weapon_data)
	_calc_weapon_triangle(result, weapon_data)
	_calc_hit_rate(result, weapon_data)
	_calc_crit_rate(result, weapon_data)
	_calc_damage(result, weapon_data)
	_calc_counter(result, weapon_data)
	_calc_follow_up(result, weapon_data)
	return result

func execute(attacker: Node, defender: Node, weapon_id: String, skill_service = null) -> void:
	var result: Dictionary = simulate(attacker, defender, weapon_id)
	combat_started.emit(attacker.unit_id, defender.unit_id)
	_apply_result(result, skill_service)
	_consume_weapon_durability(attacker, weapon_id)
	combat_finished.emit(result)

func _consume_weapon_durability(unit: Node, weapon_id: String) -> void:
	if unit and unit.runtime_state and unit.runtime_state.has_method("consume_weapon_durability"):
		unit.runtime_state.consume_weapon_durability(weapon_id)

func _create_result(attacker: Node, defender: Node, weapon_id: String, weapon_data: Dictionary) -> Dictionary:
	return {
		"attacker_id": attacker.unit_id,
		"defender_id": defender.unit_id,
		"weapon_id": weapon_id,
		"attacker_ref": attacker,
		"defender_ref": defender,
		"hit_rate": 0,
		"crit_rate": 0,
		"damage": 0,
		"is_magic": weapon_data.get("is_magic", false),
		"did_hit": false,
		"did_crit": false,
		"did_counter": false,
		"did_follow_up": false,
		"counter_hit_rate": 0,
		"counter_damage": 0,
		"triangle_advantage": false,
		"triangle_hit_bonus": 0,
		"triangle_dmg_bonus": 0,
		"applied_effects": []
	}

func _calc_weapon_triangle(result: Dictionary, weapon_data: Dictionary) -> void:
	var atk_type: String = weapon_data.get("type", "")
	if atk_type == "" or not result.has("defender_ref"):
		return
	var defender: Node = result["defender_ref"] as Node
	if not defender or not defender.runtime_state:
		return
	var def_weapon_id: String = defender.runtime_state.equipped_weapon
	if def_weapon_id == "":
		return
	var def_weapon: Dictionary = DataManager.get_weapon(def_weapon_id)
	var def_type: String = def_weapon.get("type", "")
	if def_type == "":
		return
	if WEAPON_TRIANGLE.get(atk_type, "") == def_type:
		result["triangle_advantage"] = true
		result["triangle_hit_bonus"] = 15
		result["triangle_dmg_bonus"] = 1
	elif WEAPON_TRIANGLE.get(def_type, "") == atk_type:
		result["triangle_hit_bonus"] = -15
		result["triangle_dmg_bonus"] = -1

func _calc_hit_rate(result: Dictionary, weapon_data: Dictionary) -> void:
	var attacker: Node = result["attacker_ref"] as Node
	var defender: Node = result["defender_ref"] as Node
	if not attacker or not defender or not attacker.runtime_state or not defender.runtime_state:
		result["hit_rate"] = 50
		return
	result["hit_rate"] = _calc_hit_value(attacker, defender, weapon_data, result.get("triangle_hit_bonus", 0))

func _calc_crit_rate(result: Dictionary, weapon_data: Dictionary) -> void:
	var attacker: Node = result["attacker_ref"] as Node
	if not attacker or not attacker.runtime_state:
		result["crit_rate"] = 0
		return
	var base_crit: int = weapon_data.get("crit", 0)
	var skl: int = attacker.runtime_state.skl_stat
	result["crit_rate"] = min(50, max(0, skl / 2 + base_crit))

func _calc_damage(result: Dictionary, weapon_data: Dictionary) -> void:
	var attacker: Node = result["attacker_ref"] as Node
	var defender: Node = result["defender_ref"] as Node
	if not attacker or not defender or not attacker.runtime_state or not defender.runtime_state:
		result["damage"] = 0
		return
	var might: int = weapon_data.get("might", 0)
	var tri_dmg: int = result.get("triangle_dmg_bonus", 0)
	var is_magic: bool = result.get("is_magic", false)
	var atk_stat: int = attacker.runtime_state.mag_stat if is_magic else attacker.runtime_state.str_stat
	var def_stat: int = defender.runtime_state.res_stat if is_magic else defender.runtime_state.def_stat
	var terrain_bonus: int = _get_terrain_bonus(defender, "defense_bonus") if not is_magic else 0
	var base_damage: int = max(0, atk_stat + might + tri_dmg - (def_stat + terrain_bonus))
	var effective_tags: Array = weapon_data.get("effective_tags", [])
	for tag in effective_tags:
		if _unit_has_tag(defender, str(tag)):
			base_damage = int(base_damage * 1.5)
			break
	result["damage"] = base_damage

func _calc_counter(result: Dictionary, weapon_data: Dictionary) -> void:
	var attacker: Node = result["attacker_ref"] as Node
	var defender: Node = result["defender_ref"] as Node
	if not attacker or not defender or not attacker.runtime_state or not defender.runtime_state:
		result["did_counter"] = false
		return
	var def_weapon_id: String = defender.runtime_state.equipped_weapon
	if def_weapon_id == "":
		result["did_counter"] = false
		return
	var def_weapon: Dictionary = DataManager.get_weapon(def_weapon_id)
	if def_weapon.is_empty():
		result["did_counter"] = false
		return
	if not _can_counter(attacker, defender, def_weapon):
		result["did_counter"] = false
		return
	result["did_counter"] = true
	var def_might: int = def_weapon.get("might", 0)
	var is_magic: bool = def_weapon.get("is_magic", false)
	var atk_stat: int = defender.runtime_state.mag_stat if is_magic else defender.runtime_state.str_stat
	var def_stat: int = attacker.runtime_state.res_stat if is_magic else attacker.runtime_state.def_stat
	var counter_triangle := _calc_triangle_damage_bonus(def_weapon.get("type", ""), weapon_data.get("type", ""))
	var terrain_bonus: int = _get_terrain_bonus(attacker, "defense_bonus") if not is_magic else 0
	result["counter_damage"] = max(0, atk_stat + def_might + counter_triangle - (def_stat + terrain_bonus))
	var counter_hit_bonus := _calc_triangle_hit_bonus(def_weapon.get("type", ""), weapon_data.get("type", ""))
	result["counter_hit_rate"] = _calc_hit_value(defender, attacker, def_weapon, counter_hit_bonus)

func _calc_follow_up(result: Dictionary, weapon_data: Dictionary) -> void:
	var attacker: Node = result["attacker_ref"] as Node
	var defender: Node = result["defender_ref"] as Node
	if not attacker or not defender or not attacker.runtime_state or not defender.runtime_state:
		result["did_follow_up"] = false
		return
	var atk_weight: int = weapon_data.get("weight", 0)
	var atk_spd: int = attacker.runtime_state.spd_stat - atk_weight
	var def_weapon_id: String = defender.runtime_state.equipped_weapon
	var def_weight: int = 0
	if def_weapon_id != "":
		var def_weapon: Dictionary = DataManager.get_weapon(def_weapon_id)
		def_weight = def_weapon.get("weight", 0)
	var def_spd: int = defender.runtime_state.spd_stat - def_weight
	result["did_follow_up"] = max(0, atk_spd) >= max(0, def_spd) + 4

func _apply_result(result: Dictionary, skill_service = null) -> void:
	var attacker: Node = result.get("attacker_ref") as Node
	var defender: Node = result.get("defender_ref") as Node
	if not attacker or not defender or not attacker.runtime_state or not defender.runtime_state:
		return
	var hit_roll: int = randi() % 100
	if hit_roll < result.get("hit_rate", 0):
		result["did_hit"] = true
		var crit_roll: int = randi() % 100
		if crit_roll < result.get("crit_rate", 0):
			result["did_crit"] = true
			defender.take_damage(result.get("damage", 0) * 3)
			_remove_sleep(defender)
		else:
			defender.take_damage(result.get("damage", 0))
			_remove_sleep(defender)
		result["applied_effects"].append("attacker_hit")
		if skill_service:
			skill_service.apply_unit_passives(attacker, "on_hit")
			skill_service.apply_unit_passives(defender, "on_damage")
	else:
		result["did_hit"] = false
		result["did_miss"] = true
	if not defender.is_alive():
		result["applied_effects"].append("defender_killed")
		if skill_service:
			skill_service.apply_unit_passives(attacker, "on_kill")
			skill_service.apply_unit_passives(defender, "on_death")
		return
	if result.get("did_counter", false):
		var counter_roll: int = randi() % 100
		if counter_roll < result.get("counter_hit_rate", 0):
			attacker.take_damage(result.get("counter_damage", 0))
			_remove_sleep(attacker)
			if skill_service:
				skill_service.apply_unit_passives(attacker, "on_damage")
	_try_counter_stance(defender, attacker, result)
	if not attacker.is_alive():
		result["applied_effects"].append("attacker_killed")
		if skill_service:
			skill_service.apply_unit_passives(defender, "on_kill")
			skill_service.apply_unit_passives(attacker, "on_death")
		return
	if result.get("did_follow_up", false):
		var follow_roll: int = randi() % 100
		if follow_roll < result.get("hit_rate", 0):
			defender.take_damage(result.get("damage", 0))
			_remove_sleep(defender)
			if skill_service:
				skill_service.apply_unit_passives(defender, "on_damage")
	if not defender.is_alive():
		result["applied_effects"].append("defender_killed")
		if skill_service:
			skill_service.apply_unit_passives(attacker, "on_kill")
			skill_service.apply_unit_passives(defender, "on_death")

func _calc_hit_value(attacker: Node, defender: Node, weapon_data: Dictionary, triangle_hit_bonus: int) -> int:
	var base_hit: int = weapon_data.get("hit", 0)
	var skl: int = attacker.runtime_state.skl_stat
	var luk: int = attacker.runtime_state.luk_stat
	var target_spd: int = defender.runtime_state.spd_stat
	var target_luk: int = defender.runtime_state.luk_stat
	var avoid_bonus: int = _get_terrain_bonus(defender, "avoid_bonus")
	var height_bonus: int = 0
	var h_diff: int = _get_height(attacker) - _get_height(defender)
	if h_diff > 0:
		height_bonus = 10
	elif h_diff < 0:
		height_bonus = -10
	var raw: int = base_hit + skl * 2 + luk + triangle_hit_bonus + height_bonus - (target_spd / 2 + target_luk + avoid_bonus)
	return clampi(raw, 0, 100)

func _unit_has_tag(unit: Node, tag: String) -> bool:
	if not unit or not unit.runtime_state:
		return false
	return tag in unit.runtime_state.tags

func _remove_sleep(unit: Node) -> void:
	if not unit or not unit.runtime_state:
		return
	var effects: Array[Dictionary] = unit.runtime_state.status_effects
	var filtered: Array[Dictionary] = []
	for e in effects:
		if str(e.get("id", "")) != "sleep":
			filtered.append(e)
	unit.runtime_state.status_effects = filtered

func _try_counter_stance(defender: Node, attacker: Node, result: Dictionary) -> void:
	if not defender or not defender.runtime_state:
		return
	var stance_idx := -1
	for i in range(defender.runtime_state.status_effects.size()):
		var e: Dictionary = defender.runtime_state.status_effects[i]
		if str(e.get("id", "")) == "counter_stance":
			stance_idx = i
			break
	if stance_idx < 0:
		return
	var stance: Dictionary = defender.runtime_state.status_effects[stance_idx]
	var chance: int = int(stance.get("counter_chance", 30))
	var dmg_pct: float = float(stance.get("damage_percent", 50)) / 100.0
	defender.runtime_state.status_effects.remove_at(stance_idx)
	if randi() % 100 < chance:
		var counter_dmg: int = int(result.get("damage", 0) * dmg_pct)
		if counter_dmg > 0:
			attacker.take_damage(counter_dmg)
			result["counter_stance_triggered"] = true
			result["counter_stance_damage"] = counter_dmg

func _get_terrain_bonus(unit: Node, key: String) -> int:
	if _battle_query and _battle_query.has_method("get_terrain_data_at"):
		var terrain_data: Dictionary = _battle_query.get_terrain_data_at(unit.grid_pos)
		return int(terrain_data.get(key, 0))
	return 0

func _get_height(unit: Node) -> int:
	return _get_terrain_bonus(unit, "height")

func _get_distance(attacker: Node, defender: Node) -> int:
	if _battle_query and _battle_query.has_method("get_distance"):
		return int(_battle_query.get_distance(attacker.grid_pos, defender.grid_pos))
	return abs(attacker.grid_pos.x - defender.grid_pos.x) + abs(attacker.grid_pos.y - defender.grid_pos.y)

func _can_counter(attacker: Node, defender: Node, defender_weapon: Dictionary) -> bool:
	var distance := _get_distance(attacker, defender)
	var min_range: int = defender_weapon.get("min_range", 1)
	var max_range: int = defender_weapon.get("max_range", 1)
	if not (distance >= min_range and distance <= max_range):
		return false
	if not defender.runtime_state:
		return false
	for e in defender.runtime_state.status_effects:
		var eid: String = str(e.get("id", ""))
		if eid in ["sleep", "paralysis"] and e.get("duration", 0) > 0:
			return false
	return true

func _calc_triangle_hit_bonus(attacker_type: String, defender_type: String) -> int:
	if attacker_type == "" or defender_type == "":
		return 0
	if WEAPON_TRIANGLE.get(attacker_type, "") == defender_type:
		return 15
	if WEAPON_TRIANGLE.get(defender_type, "") == attacker_type:
		return -15
	return 0

func _calc_triangle_damage_bonus(attacker_type: String, defender_type: String) -> int:
	if attacker_type == "" or defender_type == "":
		return 0
	if WEAPON_TRIANGLE.get(attacker_type, "") == defender_type:
		return 1
	if WEAPON_TRIANGLE.get(defender_type, "") == attacker_type:
		return -1
	return 0