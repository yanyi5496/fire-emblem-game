extends RefCounted

class_name BattleLifecycleService

func build_snapshot(units_container: Node, turn_number: int, map_id: String) -> Dictionary:
	var units: Array[Dictionary] = []
	if units_container:
		for unit in units_container.get_children():
			if unit.has_method("to_save_dict"):
				units.append(unit.to_save_dict())
	var map_state := {
		"map_id": map_id,
		"turn": turn_number,
	}
	GameState.update_battle_snapshot(units, map_state)
	return {
		"units": units,
		"map_state": map_state,
	}

func save_checkpoint(slot: int, units_container: Node, turn_number: int, map_id: String) -> bool:
	var snapshot: Dictionary = build_snapshot(units_container, turn_number, map_id)
	return SaveManager.save_game(slot, snapshot)

func finalize_battle(result: String, units_container: Node, turn_number: int, map_id: String, current_chapter: String) -> Dictionary:
	var snapshot: Dictionary = build_snapshot(units_container, turn_number, map_id)
	GameState.record_battle_result(result, map_id, turn_number)
	GameState.set_resume_scene("result")
	if result == "victory":
		if map_id != "" and map_id not in GameState.completed_maps:
			GameState.completed_maps.append(map_id)
		if current_chapter != "":
			GameState.story_flags["%s_cleared" % current_chapter] = true
	var saved: bool = SaveManager.save_game(1, snapshot)
	GameState.set_phase(GameState.GamePhase.BATTLE_RESULT)
	return {
		"saved": saved,
		"snapshot": snapshot,
	}
