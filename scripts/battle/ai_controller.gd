extends Node

class_name AIController

enum AIType { AGGRESSIVE, DEFENSIVE, SUPPORT, BOSS, PATROL }

const SCORE_KILL := 100
const SCORE_LOW_HP := 30
const SCORE_DAMAGE_PER_HP := 3
const SCORE_HEAL := 40
const SCORE_TARGET_HEALER := 20
const SCORE_SELF_BUFF := 15
const SCORE_NEAREST := 10
const SCORE_MOVE_TO_ATTACK := 5

var _combat_manager = null
var _battle_controller: Node = null

func initialize(battle_controller: Node) -> void:
	_battle_controller = battle_controller

func _get_combat_manager():
	if _battle_controller and _battle_controller.combat_manager:
		return _battle_controller.combat_manager
	if _combat_manager == null:
		_combat_manager = CombatManager.new()
		if _battle_controller and _battle_controller.battle_query:
			_combat_manager.initialize(_battle_controller.battle_query)
	return _combat_manager

func execute_turn(units: Array[Node]) -> void:
	for unit in units:
		if not unit.is_alive():
			continue
		if unit.runtime_state.action_state != GameConstants.ActionState.IDLE:
			continue
		if _is_disabled(unit):
			continue
		var action := _decide_action(unit)
		_execute_action(unit, action)

func _is_disabled(unit: Node) -> bool:
	if not unit.runtime_state:
		return true
	for e in unit.runtime_state.status_effects:
		var eid: String = str(e.get("id", ""))
		if eid in ["sleep", "paralysis"] and e.get("duration", 0) > 0:
			return true
	return false

func _decide_action(unit: Node) -> Dictionary:
	if not _battle_controller:
		return { "type": "wait" }
	var ai_type: String = unit.runtime_state.ai_type if unit.runtime_state else "aggressive"
	match ai_type:
		"defensive":
			return _decide_defensive(unit, _battle_controller)
		"support":
			return _decide_support(unit, _battle_controller)
		"patrol", "boss":
			return _decide_aggressive(unit, _battle_controller)
		_:
			return _decide_aggressive(unit, _battle_controller)

func _decide_aggressive(unit: Node, battle_controller: Node) -> Dictionary:
	var best_action := { "type": "wait", "score": -999 }
	var in_range_targets: Array = battle_controller.get_enemies_in_range(unit)
	for target in in_range_targets:
		var score := _evaluate_attack(unit, target)
		if score > best_action.get("score", -999):
			best_action = { "type": "attack", "target": target, "score": score }
	var heal_target = _evaluate_heal(unit)
	if heal_target != null:
		var heal_score: int = SCORE_HEAL
		if heal_score > best_action.get("score", -999):
			best_action = { "type": "heal", "target": heal_target, "score": heal_score }
	var self_buff_skill := _evaluate_self_buff(unit)
	if self_buff_skill != "":
		var buff_score: int = SCORE_SELF_BUFF
		if buff_score > best_action.get("score", -999):
			best_action = { "type": "self_buff", "skill_id": self_buff_skill, "score": buff_score }
	if best_action.get("type", "wait") in ["attack", "heal", "self_buff"]:
		return best_action
	var move_target: Vector2i = _find_move_target(unit, battle_controller)
	if move_target != unit.grid_pos:
		var move_score: int = _evaluate_move_target(unit, move_target, battle_controller)
		return { "type": "move", "target_pos": move_target, "score": move_score }
	return best_action

func _decide_defensive(unit: Node, battle_controller: Node) -> Dictionary:
	var best_action := { "type": "wait", "score": -999 }
	var heal_target = _evaluate_heal(unit)
	if heal_target != null:
		var heal_score: int = SCORE_HEAL + 10
		best_action = { "type": "heal", "target": heal_target, "score": heal_score }
	var self_buff_skill := _evaluate_self_buff(unit)
	if self_buff_skill != "" and best_action.get("type", "wait") != "heal":
		var buff_score: int = SCORE_SELF_BUFF + 15
		best_action = { "type": "self_buff", "skill_id": self_buff_skill, "score": buff_score }
	var in_range_targets: Array = battle_controller.get_enemies_in_range(unit)
	for target in in_range_targets:
		var score := _evaluate_attack(unit, target)
		if best_action.get("type", "wait") == "heal":
			score -= 30
		if score > best_action.get("score", -999):
			best_action = { "type": "attack", "target": target, "score": score }
	if best_action.get("type", "wait") in ["attack", "heal", "self_buff"]:
		return best_action
	var move_target: Vector2i = _find_move_target(unit, battle_controller)
	if move_target != unit.grid_pos:
		var move_score: int = _evaluate_move_target(unit, move_target, battle_controller)
		move_score = max(0, move_score - 10)
		if move_score > 0:
			return { "type": "move", "target_pos": move_target, "score": move_score }
	return best_action

func _decide_support(unit: Node, battle_controller: Node) -> Dictionary:
	var best_action := { "type": "wait", "score": -999 }
	var heal_target = _evaluate_heal(unit)
	if heal_target != null:
		var heal_score: int = SCORE_HEAL * 3
		best_action = { "type": "heal", "target": heal_target, "score": heal_score }
	var self_buff_skill := _evaluate_self_buff(unit)
	if self_buff_skill != "":
		var buff_score: int = SCORE_SELF_BUFF
		if buff_score > best_action.get("score", -999):
			best_action = { "type": "self_buff", "skill_id": self_buff_skill, "score": buff_score }
	var in_range_targets: Array = battle_controller.get_enemies_in_range(unit)
	for target in in_range_targets:
		var score := _evaluate_attack(unit, target)
		score = max(0, score - 40)
		if score > best_action.get("score", -999):
			best_action = { "type": "attack", "target": target, "score": score }
	if best_action.get("type", "wait") in ["heal", "self_buff", "attack"]:
		return best_action
	return best_action

func _is_healer(unit: Node) -> bool:
	if not unit or not unit.runtime_state:
		return false
	for skill_id in unit.runtime_state.skills:
		var data: Dictionary = DataManager.get_skill(skill_id)
		if data.get("effect", {}).get("type", "") == "heal":
			return true
	return false

func _evaluate_attack(attacker: Node, target: Node) -> int:
	var score := 0
	var combat = _get_combat_manager()
	var weapon_id: String = attacker.runtime_state.equipped_weapon
	if weapon_id == "":
		return -999
	var result = combat.simulate(attacker, target, weapon_id)
	var damage = result.get("damage", 0)
	if damage >= target.get_current_hp():
		score += SCORE_KILL
	score += damage * SCORE_DAMAGE_PER_HP
	if target.get_current_hp() < target.get_max_hp() * 0.3:
		score += SCORE_LOW_HP
	if _is_healer(target):
		score += SCORE_TARGET_HEALER
	return score

func _evaluate_heal(unit: Node):
	if not unit.runtime_state:
		return null
	if not _battle_controller:
		return null
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") != "active":
			continue
		if not unit.runtime_state.can_use_skill(skill_id):
			continue
		if skill_data.get("effect", {}).get("type", "") == "heal":
			var allies: Array = _battle_controller.skill_service.get_skill_targets(
				unit,
				skill_id,
				_battle_controller.battle_query,
				_battle_controller.pathfinding,
				_battle_controller.tile_map
			)
			if allies.is_empty():
				return null
			var best_ally = allies[0]
			var lowest_hp: int = best_ally.get_current_hp()
			for ally in allies:
				if ally.get_current_hp() < lowest_hp:
					lowest_hp = ally.get_current_hp()
					best_ally = ally
			return best_ally
	return null

func _evaluate_move_target(unit: Node, tile: Vector2i, battle_controller: Node) -> int:
	var score := 0
	var targets: Array = battle_controller.get_enemy_units_for(unit)
	if targets.is_empty():
		return score
	var nearest_dist: int = 999
	for target in targets:
		var dist: int = battle_controller.get_distance(tile, target.grid_pos)
		if dist < nearest_dist:
			nearest_dist = dist
	score = max(0, 30 - nearest_dist)
	return score

func _evaluate_self_buff(unit: Node) -> String:
	if not unit or not unit.runtime_state:
		return ""
	for skill_id in unit.runtime_state.skills:
		var data: Dictionary = DataManager.get_skill(skill_id)
		if data.get("type", "") != "active":
			continue
		if not unit.runtime_state.can_use_skill(skill_id):
			continue
		var effect: Dictionary = data.get("effect", {})
		if effect.get("type", "") == "stat_bonus" and str(effect.get("target", "")) == "self":
			return skill_id
	return ""

func _execute_action(unit: Node, action: Dictionary) -> void:
	match action.get("type", "wait"):
		"attack":
			var target = action.get("target")
			var weapon_id: String = unit.runtime_state.equipped_weapon
			if target and weapon_id != "":
				var weapon_type: String = DataManager.get_weapon(weapon_id).get("type", "")
				if not unit.runtime_state.can_equip_weapon_type(weapon_type):
					unit.wait()
					return
				if _battle_controller and _battle_controller.combat_exec_service:
					_battle_controller.combat_exec_service.execute_attack(unit, target, weapon_id, _get_combat_manager(), _get_skill_service_from_controller(), _battle_controller.battle_hud)
				else:
					var active_skill_service = _get_skill_service_from_controller()
					if active_skill_service:
						active_skill_service.apply_unit_passives(unit, "before_combat")
						active_skill_service.apply_unit_passives(target, "before_combat")
					unit.attack(target)
					_get_combat_manager().execute(unit, target, weapon_id, active_skill_service)
					if active_skill_service:
						active_skill_service.apply_unit_passives(unit, "after_combat")
						active_skill_service.apply_unit_passives(target, "after_combat")
						active_skill_service.clear_temporary_passives(unit)
						active_skill_service.clear_temporary_passives(target)
			else:
				unit.wait()
		"self_buff":
			var skill_id: String = str(action.get("skill_id", ""))
			if skill_id == "":
				unit.wait()
				return
			var active_skill_service = _get_skill_service_from_controller()
			if not _execute_self_buff_action(unit, skill_id, active_skill_service):
				unit.wait()
		"move":
			if _battle_controller:
				_battle_controller.move_unit_to(unit, action.get("target_pos", unit.grid_pos))
				var follow_up_action := _best_attack_action(unit, _battle_controller)
				if follow_up_action.get("type", "wait") == "attack":
					_execute_action(unit, follow_up_action)
				else:
					var heal_target = _evaluate_heal(unit)
					if heal_target != null:
						_execute_skill_heal(unit, heal_target, _battle_controller)
					else:
						unit.wait()
			else:
				unit.wait()
		_:
			unit.wait()

func _get_skill_service_from_controller():
	if _battle_controller and _battle_controller.skill_service:
		return _battle_controller.skill_service
	return null

func _execute_self_buff_action(unit: Node, skill_id: String, active_skill_service) -> bool:
	if not unit or skill_id == "" or not active_skill_service:
		return false
	var result: Dictionary = active_skill_service.execute_skill(unit, unit, skill_id)
	return bool(result.get("success", false))

func _execute_skill_heal(unit: Node, target: Node, battle_controller: Node) -> void:
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") != "active":
			continue
		if not unit.runtime_state.can_use_skill(skill_id):
			continue
		if skill_data.get("effect", {}).get("type", "") == "heal":
			var result: Dictionary = battle_controller.skill_service.execute_skill(unit, target, skill_id)
			if result.get("success", false):
				return
			return
	unit.wait()

func _best_attack_action(unit: Node, battle_controller: Node) -> Dictionary:
	var in_range_targets: Array = battle_controller.get_enemies_in_range(unit)
	var best_action := { "type": "wait", "score": -999 }
	for target in in_range_targets:
		var score := _evaluate_attack(unit, target)
		if score > best_action.get("score", -999):
			best_action = { "type": "attack", "target": target, "score": score }
	return best_action

func _find_move_target(unit: Node, battle_controller: Node) -> Vector2i:
	var targets: Array = battle_controller.get_enemy_units_for(unit)
	if targets.is_empty():
		return unit.grid_pos
	var primary_target: Node = _select_primary_target(unit, targets, battle_controller)
	var path: Array[Vector2i] = battle_controller.pathfinding.find_path(unit.grid_pos, primary_target.grid_pos, battle_controller.tile_map)
	if path.size() <= 1:
		return unit.grid_pos
	var best_tile: Vector2i = unit.grid_pos
	var spent_cost := 0
	for i in range(1, path.size()):
		var step: Vector2i = path[i]
		if step == primary_target.grid_pos:
			break
		var move_cost: int = int(battle_controller.get_terrain_data_at(step).get("move_cost", 1))
		if spent_cost + move_cost > unit.runtime_state.mov_stat:
			break
		var occupied = battle_controller.get_unit_at(step)
		if occupied and occupied != unit:
			break
		spent_cost += move_cost
		best_tile = step
	if best_tile != unit.grid_pos:
		return best_tile
	var candidates: Array[Vector2i] = battle_controller.get_walkable_tiles_for(unit)
	if candidates.is_empty():
		return unit.grid_pos
	var best_score: int = battle_controller.get_distance(unit.grid_pos, primary_target.grid_pos) * 2
	var best_candidate: Vector2i = unit.grid_pos
	for tile in candidates:
		var in_range_after_move: Array = _enemies_in_range_from(unit, tile, battle_controller)
		var tile_score: int = 0
		if not in_range_after_move.is_empty():
			tile_score += SCORE_MOVE_TO_ATTACK * in_range_after_move.size()
		var dist: int = battle_controller.get_distance(tile, primary_target.grid_pos)
		tile_score += max(0, 30 - dist)
		if tile_score > best_score:
			best_score = tile_score
			best_candidate = tile
	return best_candidate

func _enemies_in_range_from(unit: Node, from_pos: Vector2i, battle_controller: Node) -> Array:
	var result: Array = []
	var weapon_data: Dictionary = DataManager.get_weapon(unit.runtime_state.equipped_weapon)
	if weapon_data.is_empty():
		return result
	var min_range: int = weapon_data.get("min_range", 1)
	var max_range: int = weapon_data.get("max_range", 1)
	var attack_tiles: Array[Vector2i] = battle_controller.pathfinding.get_attack_range(from_pos, min_range, max_range, battle_controller.tile_map)
	for tile in attack_tiles:
		var enemy = battle_controller.get_unit_at(tile)
		if enemy and enemy.team != unit.team and enemy.is_alive():
			result.append(enemy)
	return result

func _select_primary_target(unit: Node, targets: Array, battle_controller: Node) -> Node:
	var best_target: Node = targets[0]
	var best_score := -999
	for target in targets:
		var score := _evaluate_attack(unit, target)
		if score > best_score:
			best_score = score
			best_target = target
	return best_target