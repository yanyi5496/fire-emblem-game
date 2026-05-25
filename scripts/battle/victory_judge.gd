extends RefCounted

class_name VictoryJudge

var map_data: Dictionary = {}
var lord_unit_id: String = ""

func setup(map_data: Dictionary) -> void:
	self.map_data = map_data
	lord_unit_id = str(map_data.get("lord_unit_id", ""))

func check_victory(enemy_alive: bool, player_alive: bool, turn_number: int, lord_alive: bool = true, lord_on_escape: bool = false, all_on_escape: bool = false, capture_points: Dictionary = {}) -> String:
	if not _is_defeat_condition_met(player_alive, turn_number, lord_alive):
		var victory_condition: String = str(map_data.get("victory_condition", "rout"))
		match victory_condition:
			"rout":
				if not enemy_alive:
					return "victory"
			"defend", "survive":
				if _is_turn_limit_reached(turn_number) and player_alive:
					return "victory"
			"escape":
				return _check_escape_victory(lord_alive, lord_on_escape, all_on_escape)
			_:
				if not enemy_alive:
					return "victory"
	if _is_defeat_condition_met(player_alive, turn_number, lord_alive):
		return "defeat"
	return ""

func _check_escape_victory(lord_alive: bool, lord_on_escape: bool, all_on_escape: bool) -> String:
	var escape_type: String = str(map_data.get("escape_type", "escape_lord"))
	match escape_type:
		"escape_lord":
			if lord_unit_id != "" and lord_on_escape:
				return "victory"
			return ""
		"escape_all":
			if all_on_escape and lord_alive:
				return "victory"
			return ""
		_:
			return ""

func has_battle_ended(enemy_alive: bool, player_alive: bool, turn_number: int) -> bool:
	return check_victory(enemy_alive, player_alive, turn_number) != ""

func _is_defeat_condition_met(player_alive: bool, turn_number: int, lord_alive: bool = true) -> bool:
	var defeat_condition: String = str(map_data.get("defeat_condition", "all_dead"))
	var victory_condition: String = str(map_data.get("victory_condition", "rout"))
	if not player_alive:
		return true
	if _is_turn_limit_reached(turn_number) and victory_condition not in ["defend", "survive"]:
		return true
	match defeat_condition:
		"all_dead":
			return not player_alive
		"lord_dead":
			if lord_unit_id != "" and not lord_alive:
				return true
			return not player_alive
		"turn_limit":
			if victory_condition in ["defend", "survive"]:
				return false
			return _is_turn_limit_reached(turn_number)
		_:
			return false

func _is_turn_limit_reached(turn_number: int) -> bool:
	var max_turns: int = int(map_data.get("max_turns", 0))
	return max_turns > 0 and turn_number > max_turns
