extends Node

class_name TurnManager

const _ai_dep := preload("res://scripts/battle/ai_controller.gd")
const _ses_dep := preload("res://scripts/unit/status_effect_service.gd")

signal turn_started(phase: String)
signal turn_ended(phase: String)
signal round_ended()
signal battle_check_requested()
signal checkpoint_requested(slot: int)

enum Phase { PLAYER, ENEMY, NPC, ROUND_END }

var current_phase: Phase = Phase.PLAYER
var turn_number: int = 1
var ai_controller

func initialize_battle(starting_turn: int = 1) -> void:
	turn_number = max(1, starting_turn)
	GameState.set_turn(turn_number)
	ai_controller = _ai_dep.new()

func start_turn(phase_name: String) -> void:
	match phase_name:
		"player":
			current_phase = Phase.PLAYER
			_reset_unit_states()
			GameState.set_phase(GameState.GamePhase.BATTLE_PLAYER)
		"enemy":
			current_phase = Phase.ENEMY
			GameState.set_phase(GameState.GamePhase.BATTLE_ENEMY)
		"npc":
			current_phase = Phase.NPC
			GameState.set_phase(GameState.GamePhase.BATTLE_NPC)
	turn_started.emit(phase_name)
	if phase_name == "enemy":
		_execute_enemy_turn()

func _execute_enemy_turn() -> void:
	var bc := _get_battle_controller()
	if not bc:
		return
	var enemy_units: Array[Node] = []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == "enemy" and unit.is_alive():
			enemy_units.append(unit)
	ai_controller.execute_turn(enemy_units)
	battle_check_requested.emit()
	if has_battle_ended():
		return
	start_turn("player")

func has_battle_ended() -> bool:
	var bc := _get_battle_controller()
	if not bc or not bc.has_method("has_battle_ended"):
		return false
	return bc.has_battle_ended()

func end_turn() -> void:
	var phase_name := _phase_to_string(current_phase)
	turn_ended.emit(phase_name)
	match current_phase:
		Phase.PLAYER:
			start_turn("enemy")
		Phase.ENEMY:
			start_turn("npc")
		Phase.NPC:
			_execute_round_end()

func _execute_round_end() -> void:
	current_phase = Phase.ROUND_END
	_process_poison_damage()
	_process_debuff_ticks()
	_process_buff_ticks()
	_process_auto_heal()
	_process_skill_cooldowns()
	_reset_unit_states()
	turn_number += 1
	GameState.set_turn(turn_number)
	checkpoint_requested.emit(1)
	round_ended.emit()
	battle_check_requested.emit()
	if has_battle_ended():
		return
	start_turn("player")

func _get_battle_controller() -> Node:
	var tree := get_tree()
	if not tree:
		return null
	return tree.current_scene

func _reset_unit_states() -> void:
	var units := get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.is_alive():
			unit.reset_action_state()

func _process_buff_ticks() -> void:
	pass

func _process_debuff_ticks() -> void:
	var service = _ses_dep.new()
	var units := get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.is_alive():
			service.tick_effect_durations(unit)

func _process_poison_damage() -> void:
	var service = _ses_dep.new()
	var units := get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.is_alive():
			service.apply_poison_tick(unit)

func _process_auto_heal() -> void:
	var units := get_tree().get_nodes_in_group("units")
	for unit in units:
		if not unit.is_alive():
			continue
		if _has_turn_end_heal(unit):
			unit.heal(2)

func _process_skill_cooldowns() -> void:
	var units := get_tree().get_nodes_in_group("units")
	for unit in units:
		if not unit.is_alive() or not unit.runtime_state:
			continue
		var cooldowns: Dictionary = unit.runtime_state.skill_cooldowns
		for skill_id in cooldowns.keys():
			cooldowns[skill_id] = max(0, int(cooldowns[skill_id]) - 1)
		unit.runtime_state.skill_cooldowns = cooldowns

func _has_turn_end_heal(unit) -> bool:
	if not unit.runtime_state:
		return false
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("trigger", "") == "turn_end" and skill_data.get("effect", {}).get("type", "") == "heal":
			return true
	return false

func _phase_to_string(phase: Phase) -> String:
	match phase:
		Phase.PLAYER: return "player"
		Phase.ENEMY: return "enemy"
		Phase.NPC: return "npc"
		Phase.ROUND_END: return "round_end"
	return ""
