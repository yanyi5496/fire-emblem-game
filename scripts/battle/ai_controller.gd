extends Node

class_name AIController

enum AIType { AGGRESSIVE, DEFENSIVE, SUPPORT, BOSS, PATROL }

func execute_turn(units: Array[Node]) -> void:
	for unit in units:
		if not unit.is_alive():
			continue
		if unit.runtime_state.action_state != UnitRuntimeState.ActionState.IDLE:
			continue
		var action := _decide_action(unit)
		_execute_action(unit, action)

func _decide_action(unit: Node) -> Dictionary:
	var targets := _find_targets(unit)
	if targets.is_empty():
		return { "type": "wait" }

	var best_action := { "type": "wait", "score": -999 }
	for target in targets:
		var score := _evaluate_attack(unit, target)
		if score > best_action.score:
			best_action = { "type": "attack", "target": target, "score": score }
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
	var combat := CombatManager.new()
	var result := combat.simulate(attacker, target, "")
	if result.damage >= target.get_current_hp():
		score += 100
	score += result.damage * 3
	if target.get_current_hp() < target.get_max_hp() * 0.3:
		score += 30
	return score

func _execute_action(unit: Node, action: Dictionary) -> void:
	match action.type:
		"attack":
			unit.attack(action.target)
		_:
			unit.wait()
