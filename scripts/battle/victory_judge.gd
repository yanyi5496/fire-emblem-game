extends RefCounted

class_name VictoryJudge

var map_data: Dictionary = {}

func setup(map_data: Dictionary) -> void:
	self.map_data = map_data

func check_victory(enemy_alive: bool, player_alive: bool, turn_number: int) -> String:
	if not _is_defeat_condition_met(player_alive, turn_number):
		var victory_condition: String = str(map_data.get("victory_condition", "rout"))
		match victory_condition:
			"rout":
				if not enemy_alive:
					return "victory"
			"defend", "survive":
				if _is_turn_limit_reached(turn_number) and player_alive:
					return "victory"
			_:
				if not enemy_alive:
					return "victory"
	if _is_defeat_condition_met(player_alive, turn_number):
		return "defeat"
	return ""

func has_battle_ended(enemy_alive: bool, player_alive: bool, turn_number: int) -> bool:
	return check_victory(enemy_alive, player_alive, turn_number) != ""

func _is_defeat_condition_met(player_alive: bool, turn_number: int) -> bool:
	var defeat_condition: String = str(map_data.get("defeat_condition", "all_dead"))
	var victory_condition: String = str(map_data.get("victory_condition", "rout"))
	if not player_alive:
		return true
	if _is_turn_limit_reached(turn_number) and victory_condition not in ["defend", "survive"]:
		return true
	match defeat_condition:
		"all_dead", "lord_dead":
			return not player_alive
		"turn_limit":
			return _is_turn_limit_reached(turn_number)
		_:
			return false

func _is_turn_limit_reached(turn_number: int) -> bool:
	var max_turns: int = int(map_data.get("max_turns", 0))
	return max_turns > 0 and turn_number > max_turns
