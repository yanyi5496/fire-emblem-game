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

func begin_battle(map_id: String, starting_turn: int = 1) -> void:
	current_map_id = map_id
	turn_number = max(1, starting_turn)

func set_turn(new_turn: int) -> void:
	turn_number = max(0, new_turn)

func set_phase(new_phase: GamePhase) -> void:
	if new_phase == current_phase:
		return
	previous_phase = current_phase
	var old := current_phase
	current_phase = new_phase
	_sync_input_mode(new_phase)
	phase_changed.emit(old, new_phase)

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
		"story_flags": story_flags.duplicate(),
		"completed_maps": completed_maps.duplicate(),
	}

func from_dict(data: Dictionary) -> void:
	current_chapter = data.get("chapter", "")
	current_map_id = data.get("map_id", "")
	turn_number = data.get("turn", 0)
	gold = data.get("gold", 0)
	inventory = data.get("inventory", []).duplicate()
	story_flags = data.get("story_flags", {}).duplicate()
	completed_maps = data.get("completed_maps", []).duplicate()

func reset() -> void:
	current_chapter = ""
	current_map_id = ""
	set_turn(0)
	story_flags.clear()
	completed_maps.clear()
	gold = 0
	inventory.clear()
	set_phase(GamePhase.NONE)
