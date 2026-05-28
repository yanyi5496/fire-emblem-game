extends Node

class_name TurnManager

signal turn_started(phase: String)
signal turn_ended(phase: String)
signal round_ended()
signal battle_check_requested()
signal checkpoint_requested(slot: int)

enum Phase { PLAYER, ENEMY, NPC, ROUND_END }

var current_phase: Phase = Phase.PLAYER
var turn_number: int = 1
var ai_controller
var battle_controller: Node = null
var _settlement_service: TurnSettlementService = null

func initialize_battle(starting_turn: int = 1, controller: Node = null) -> void:
	turn_number = max(1, starting_turn)
	GameState.set_turn(turn_number)
	battle_controller = controller
	ai_controller = AIController.new()
	add_child(ai_controller)
	if battle_controller:
		ai_controller.initialize(battle_controller)
	_settlement_service = TurnSettlementService.new()

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
	_process_passive_triggers("turn_start")
	if phase_name == "enemy":
		_execute_enemy_turn()

func _execute_enemy_turn() -> void:
	var enemy_units: Array[Node] = []
	for unit in get_tree().get_nodes_in_group("units"):
		if unit.team == "enemy" and unit.is_alive():
			enemy_units.append(unit)
	ai_controller.execute_turn(enemy_units)
	battle_check_requested.emit()
	if has_battle_ended():
		return
	_execute_round_end()

func has_battle_ended() -> bool:
	if not battle_controller or not battle_controller.has_method("has_battle_ended"):
		return false
	return battle_controller.has_battle_ended()

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
	_process_passive_triggers("turn_end")
	var units := get_tree().get_nodes_in_group("units")
	_settlement_service.process_round_end(units)
	_reset_unit_states()
	turn_number += 1
	GameState.set_turn(turn_number)
	checkpoint_requested.emit(1)
	round_ended.emit()
	battle_check_requested.emit()
	if has_battle_ended():
		return
	start_turn("player")

func _reset_unit_states() -> void:
	var units := get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.is_alive():
			unit.reset_action_state()

func _process_passive_triggers(trigger_type: String) -> void:
	if not battle_controller or not battle_controller.has_method("skill_service"):
		return
	var ss = battle_controller.skill_service
	if not ss or not ss.has_method("apply_unit_passives"):
		return
	var units := get_tree().get_nodes_in_group("units")
	_settlement_service.process_passive_triggers(units, trigger_type, ss)

func _phase_to_string(phase: Phase) -> String:
	match phase:
		Phase.PLAYER: return "player"
		Phase.ENEMY: return "enemy"
		Phase.NPC: return "npc"
		Phase.ROUND_END: return "round_end"
	return ""