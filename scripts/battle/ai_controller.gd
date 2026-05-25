extends Node

class_name AIController

const _urs_dep := preload("res://scripts/unit/unit_runtime_state.gd")
const _combat_dep := preload("res://scripts/battle/combat_manager.gd")

enum AIType { AGGRESSIVE, DEFENSIVE, SUPPORT, BOSS, PATROL }

const SCORE_KILL := 100
const SCORE_LOW_HP := 30
const SCORE_DAMAGE_PER_HP := 3
const SCORE_HEAL := 40
const SCORE_NEAREST := 10
const SCORE_MOVE_TO_ATTACK := 5

var _combat_manager = null

func _get_combat_manager():
	if _combat_manager == null:
		_combat_manager = _combat_dep.new()
	return _combat_manager

func execute_turn(units: Array[Node]) -> void:
	for unit in units:
		if not unit.is_alive():
			continue
		if unit.runtime_state.action_state != _urs_dep.ActionState.IDLE:
			continue
		var action := _decide_action(unit)
		_execute_action(unit, action)

func _decide_action(unit: Node) -> Dictionary:
	var battle_controller := _get_battle_controller(unit)
	if not battle_controller:
		return { "type": "wait" }

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

	if best_action.get("type", "wait") in ["attack", "heal"]:
		return best_action

	var move_target: Vector2i = _find_move_target(unit, battle_controller)
	if move_target != unit.grid_pos:
		var move_score: int = _evaluate_move_target(unit, move_target, battle_controller)
		return { "type": "move", "target_pos": move_target, "score": move_score }

	return best_action

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
	return score

func _evaluate_heal(unit: Node):
	if not unit.runtime_state:
		return null
	var battle_controller := _get_battle_controller(unit)
	if not battle_controller:
		return null
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") != "active":
			continue
		if not unit.runtime_state.can_use_skill(skill_id):
			continue
		if skill_data.get("effect", {}).get("type", "") == "heal":
			var allies: Array = battle_controller.skill_service.get_skill_targets(
				unit,
				skill_id,
				battle_controller.battle_query,
				battle_controller.pathfinding,
				battle_controller.tile_map
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

func _execute_action(unit: Node, action: Dictionary) -> void:
	match action.get("type", "wait"):
		"attack":
			var target = action.get("target")
			var weapon_id: String = unit.runtime_state.equipped_weapon
			if target and weapon_id != "":
				unit.attack(target)
				_get_combat_manager().execute(unit, target, weapon_id)
			else:
				unit.wait()
		"move":
			var battle_controller := _get_battle_controller(unit)
			if battle_controller:
				battle_controller.move_unit_to(unit, action.get("target_pos", unit.grid_pos))
				var follow_up_action := _best_attack_action(unit, battle_controller)
				if follow_up_action.get("type", "wait") == "attack":
					_execute_action(unit, follow_up_action)
				else:
					var heal_target = _evaluate_heal(unit)
					if heal_target != null:
						_execute_skill_heal(unit, heal_target, battle_controller)
					else:
						unit.wait()
			else:
				unit.wait()
		_:
			unit.wait()

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

func _get_battle_controller(unit: Node) -> Node:
	if not unit:
		return null
	var tree := unit.get_tree()
	if not tree:
		return null
	return tree.current_scene
