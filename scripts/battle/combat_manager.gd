extends Node

class_name CombatManager

signal combat_started(attacker_id: String, defender_id: String)
signal combat_finished(result: Dictionary)

func simulate(attacker: Node, defender: Node, weapon_id: String) -> Dictionary:
	var result := _create_result(attacker, defender, weapon_id)
	_calc_hit_rate(result)
	_calc_crit_rate(result)
	_calc_damage(result)
	_calc_counter(result)
	_calc_follow_up(result)
	return result

func execute(attacker: Node, defender: Node, weapon_id: String) -> void:
	var result := simulate(attacker, defender, weapon_id)
	combat_started.emit(attacker.unit_id, defender.unit_id)
	_apply_result(result)
	combat_finished.emit(result)

func _create_result(attacker: Node, defender: Node, weapon_id: String) -> Dictionary:
	return {
		"attacker_id": attacker.unit_id,
		"defender_id": defender.unit_id,
		"weapon_id": weapon_id,
		"hit_rate": 0,
		"crit_rate": 0,
		"damage": 0,
		"did_hit": false,
		"did_crit": false,
		"did_counter": false,
		"did_follow_up": false,
		"counter_hit_rate": 0,
		"counter_damage": 0,
		"applied_effects": []
	}

func _calc_hit_rate(result: Dictionary) -> void:
	result["hit_rate"] = 50

func _calc_crit_rate(result: Dictionary) -> void:
	result["crit_rate"] = 0

func _calc_damage(result: Dictionary) -> void:
	result["damage"] = 0

func _calc_counter(result: Dictionary) -> void:
	result["did_counter"] = false

func _calc_follow_up(result: Dictionary) -> void:
	result["did_follow_up"] = false

func _apply_result(result: Dictionary) -> void:
	pass
