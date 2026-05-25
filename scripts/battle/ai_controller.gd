extends Node

class_name AIController

const _urs_dep := preload("res://scripts/unit/unit_runtime_state.gd")
const _combat_dep := preload("res://scripts/battle/combat_manager.gd")

enum AIType { AGGRESSIVE, DEFENSIVE, SUPPORT, BOSS, PATROL }

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
	var in_range_targets: Array = battle_controller._get_enemies_in_range(unit)
	var best_action := { "type": "wait", "score": -999 }
	for target in in_range_targets:
		var score := _evaluate_attack(unit, target)
		if score > best_action.get("score", -999):
			best_action = { "type": "attack", "target": target, "score": score }
	if best_action.get("type", "wait") == "attack":
		return best_action
	var move_target: Vector2i = _find_move_target(unit, battle_controller)
	if move_target != unit.grid_pos:
		return { "type": "move", "target_pos": move_target }
	return best_action

func _find_targets(unit: Node) -> Array[Node]:
	var result: Array[Node] = []
	var units := get_tree().get_nodes_in_group("units")
	for u in units:
		if u.team == unit.team:
			continue
		if not u.is_alive():
			continue
		result.append(u)
	return result

func _evaluate_attack(attacker: Node, target: Node) -> int:
	var score := 0
	var combat = _combat_dep.new()
	var weapon_id: String = attacker.runtime_state.equipped_weapon
	if weapon_id == "":
		return -999
	var result = combat.simulate(attacker, target, weapon_id)
	var damage = result.get("damage", 0)
	if damage >= target.get_current_hp():
		score += 100
	score += damage * 3
	if target.get_current_hp() < target.get_max_hp() * 0.3:
		score += 30
	return score

func _execute_action(unit: Node, action: Dictionary) -> void:
	match action.get("type", "wait"):
		"attack":
			var target = action.get("target")
			var weapon_id: String = unit.runtime_state.equipped_weapon
			if target and weapon_id != "":
				unit.attack(target)
				_combat_dep.new().execute(unit, target, weapon_id)
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
					unit.wait()
			else:
				unit.wait()
		_:
			unit.wait()

func _best_attack_action(unit: Node, battle_controller: Node) -> Dictionary:
	var in_range_targets: Array = battle_controller._get_enemies_in_range(unit)
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
	var primary_target: Node = targets[0]
	var best_distance: int = battle_controller.get_distance(unit.grid_pos, primary_target.grid_pos)
	for target in targets:
		var distance: int = battle_controller.get_distance(unit.grid_pos, target.grid_pos)
		if distance < best_distance:
			best_distance = distance
			primary_target = target
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
	var best_score: int = best_distance
	for tile in candidates:
		var distance: int = battle_controller.get_distance(tile, primary_target.grid_pos)
		if distance < best_score:
			best_score = distance
			best_tile = tile
	return best_tile

func _get_battle_controller(unit: Node) -> Node:
	if not unit:
		return null
	var tree := unit.get_tree()
	if not tree:
		return null
	return tree.current_scene
