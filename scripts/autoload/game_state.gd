extends Node

enum GamePhase {
	TITLE,
	STORY,
	BATTLE_PREP,
	BATTLE_PLAYER,
	BATTLE_ENEMY,
	BATTLE_NPC,
	BATTLE_RESULT,
	SETTINGS,
	SAVE_LOAD,
	NONE
}

signal phase_changed(from: GamePhase, to: GamePhase)

var current_phase: GamePhase = GamePhase.NONE
var previous_phase: GamePhase = GamePhase.NONE
var current_chapter: String = ""
var current_map_id: String = ""
var turn_number: int = 0
var story_flags: Dictionary = {}
var completed_maps: Array[String] = []
var gold: int = 0
var inventory: Array[String] = []
var battle_units: Array[Dictionary] = []
var battle_map_state: Dictionary = {}
var latest_battle_result: String = ""
var latest_battle_map_id: String = ""
var latest_battle_turns: int = 0
var resume_scene: String = "main_menu"

func begin_battle(map_id: String, starting_turn: int = 1) -> void:
	current_map_id = map_id
	turn_number = max(1, starting_turn)
	resume_scene = "battle"

func set_turn(new_turn: int) -> void:
	turn_number = max(0, new_turn)

func set_phase(new_phase: GamePhase) -> void:
	if new_phase == current_phase:
		return
	assert_valid_transition(current_phase, new_phase)
	previous_phase = current_phase
	var old := current_phase
	current_phase = new_phase
	_sync_input_mode(new_phase)
	phase_changed.emit(old, new_phase)

func record_battle_result(result: String, map_id: String, turns: int) -> void:
	latest_battle_result = result
	latest_battle_map_id = map_id
	latest_battle_turns = turns

func set_resume_scene(scene_key: String) -> void:
	resume_scene = scene_key

func get_resume_scene() -> String:
	if resume_scene != "":
		return resume_scene
	if latest_battle_result != "":
		return "result"
	if current_map_id != "":
		return "battle"
	return "main_menu"

func update_battle_snapshot(units: Array[Dictionary], map_state: Dictionary) -> void:
	battle_units = units.duplicate(true)
	battle_map_state = map_state.duplicate(true)

func clear_battle_snapshot() -> void:
	battle_units.clear()
	battle_map_state.clear()

func _sync_input_mode(phase: GamePhase) -> void:
	match phase:
		GamePhase.TITLE, GamePhase.SETTINGS, GamePhase.SAVE_LOAD:
			InputManager.set_mode(InputManager.InputMode.MENU)
		GamePhase.STORY:
			InputManager.set_mode(InputManager.InputMode.DIALOGUE)
		GamePhase.BATTLE_PLAYER:
			InputManager.set_mode(InputManager.InputMode.BATTLE)
		GamePhase.BATTLE_ENEMY, GamePhase.BATTLE_NPC, GamePhase.BATTLE_PREP, GamePhase.BATTLE_RESULT:
			InputManager.set_mode(InputManager.InputMode.NONE)
		GamePhase.NONE:
			InputManager.set_mode(InputManager.InputMode.NONE)

func to_dict() -> Dictionary:
	return {
		"chapter": current_chapter,
		"map_id": current_map_id,
		"turn": turn_number,
		"gold": gold,
		"inventory": inventory.duplicate(),
		"units": battle_units.duplicate(true),
		"map_state": battle_map_state.duplicate(true),
		"story_flags": story_flags.duplicate(),
		"completed_maps": completed_maps.duplicate(),
		"resume_scene": resume_scene,
		"latest_battle_result": latest_battle_result,
		"latest_battle_map_id": latest_battle_map_id,
		"latest_battle_turns": latest_battle_turns,
	}

func from_dict(data: Dictionary) -> void:
	current_chapter = data.get("chapter", "")
	current_map_id = data.get("map_id", "")
	turn_number = data.get("turn", 0)
	gold = data.get("gold", 0)
	inventory = data.get("inventory", []).duplicate()
	battle_units = data.get("units", []).duplicate(true)
	battle_map_state = data.get("map_state", {}).duplicate(true)
	story_flags = data.get("story_flags", {}).duplicate()
	completed_maps = data.get("completed_maps", []).duplicate()
	resume_scene = str(data.get("resume_scene", "main_menu"))
	latest_battle_result = str(data.get("latest_battle_result", ""))
	latest_battle_map_id = str(data.get("latest_battle_map_id", ""))
	latest_battle_turns = int(data.get("latest_battle_turns", 0))

func is_valid_transition(from: GamePhase, to: GamePhase) -> bool:
	var allowed: Dictionary = {
		GamePhase.NONE: [GamePhase.TITLE],
		GamePhase.TITLE: [GamePhase.STORY, GamePhase.BATTLE_PREP, GamePhase.BATTLE_RESULT, GamePhase.SETTINGS, GamePhase.SAVE_LOAD],
		GamePhase.STORY: [GamePhase.BATTLE_PREP, GamePhase.NONE],
		GamePhase.BATTLE_PREP: [GamePhase.BATTLE_PLAYER],
		GamePhase.BATTLE_PLAYER: [GamePhase.BATTLE_ENEMY],
		GamePhase.BATTLE_ENEMY: [GamePhase.BATTLE_NPC, GamePhase.BATTLE_PLAYER],
		GamePhase.BATTLE_NPC: [GamePhase.BATTLE_PLAYER],
		GamePhase.BATTLE_RESULT: [GamePhase.TITLE, GamePhase.NONE],
		GamePhase.SETTINGS: [GamePhase.TITLE],
		GamePhase.SAVE_LOAD: [GamePhase.TITLE, GamePhase.STORY, GamePhase.BATTLE_PREP, GamePhase.BATTLE_RESULT],
	}
	var valid: Array = allowed.get(from, [])
	return to in valid

func assert_valid_transition(from: GamePhase, to: GamePhase) -> void:
	if not is_valid_transition(from, to):
		push_warning("Invalid phase transition: %s -> %s" % [from, to])

func reset() -> void:
	current_chapter = ""
	current_map_id = ""
	set_turn(0)
	story_flags.clear()
	completed_maps.clear()
	gold = 0
	inventory.clear()
	clear_battle_snapshot()
	latest_battle_result = ""
	latest_battle_map_id = ""
	latest_battle_turns = 0
	resume_scene = "main_menu"
	set_phase(GamePhase.NONE)
