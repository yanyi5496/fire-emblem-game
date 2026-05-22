extends Node

class_name TurnManager

signal turn_started(phase: String)
signal turn_ended(phase: String)
signal round_ended()

enum Phase { PLAYER, ENEMY, NPC, ROUND_END }

var current_phase: Phase = Phase.PLAYER
var turn_number: int = 1

func start_turn(phase_name: String) -> void:
	match phase_name:
		"player":
			current_phase = Phase.PLAYER
			_reset_unit_states()
		"enemy":
			current_phase = Phase.ENEMY
		"npc":
			current_phase = Phase.NPC
	turn_started.emit(phase_name)

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
	_process_buff_ticks()
	_process_debuff_ticks()
	_process_poison_damage()
	_process_auto_heal()
	_process_skill_cooldowns()
	_reset_unit_states()
	turn_number += 1
	round_ended.emit()
	start_turn("player")

func _reset_unit_states() -> void:
	var units := get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit.is_alive():
			unit.reset_action_state()

func _process_buff_ticks() -> void:
	pass

func _process_debuff_ticks() -> void:
	pass

func _process_poison_damage() -> void:
	pass

func _process_auto_heal() -> void:
	pass

func _process_skill_cooldowns() -> void:
	pass

func _phase_to_string(phase: Phase) -> String:
	match phase:
		Phase.PLAYER: return "player"
		Phase.ENEMY: return "enemy"
		Phase.NPC: return "npc"
		Phase.ROUND_END: return "round_end"
	return ""
