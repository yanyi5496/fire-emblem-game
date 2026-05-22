extends Node

class_name BattleController

signal battle_started()
signal battle_ended(result: String)
signal unit_selected(unit: Node)
signal action_executed(action: String)

var combat_manager: CombatManager
@onready var turn_manager: TurnManager = $TurnManager
@onready var cursor: Node2D = $Cursor
@onready var units_container: Node2D = $Units
@onready var tile_map: TileMap = $MapRoot/GroundTileMap
@onready var pathfinding: PathfindingService = $PathfindingService

var map_data: Dictionary = {}
var _battle_started_once := false

func _ready() -> void:
	combat_manager = CombatManager.new()
	if GameState.current_map_id != "":
		call_deferred("start_battle", GameState.current_map_id)

func start_battle(map_id: String) -> void:
	if _battle_started_once:
		return
	GameState.begin_battle(map_id, max(1, GameState.turn_number))
	GameState.set_phase(GameState.GamePhase.BATTLE_PREP)
	map_data = DataManager.get_map(map_id)
	if map_data.is_empty():
		push_error("Map data not found: %s" % map_id)
		return
	_battle_started_once = true
	_spawn_units()
	turn_manager.initialize_battle(GameState.turn_number)
	turn_manager.start_turn("player")
	battle_started.emit()

func _spawn_units() -> void:
	if not map_data.has("units"):
		return
	for u in map_data["units"]:
		_spawn_unit(u)

func _spawn_unit(data: Dictionary) -> void:
	var unit_scene := preload("res://scenes/battle/unit/unit.tscn")
	var unit := unit_scene.instantiate()
	unit.setup(
		data.get("unit_id", ""),
		data.get("team", ""),
		Vector2i(data.get("x", 0), data.get("y", 0))
	)
	units_container.add_child(unit)

func on_unit_clicked(unit: Node) -> void:
	unit_selected.emit(unit)

func check_victory_condition() -> String:
	var player_alive := false
	var enemy_alive := false
	for unit in units_container.get_children():
		if unit.is_alive():
			match unit.team:
				"player": player_alive = true
				"enemy": enemy_alive = true
	if not enemy_alive:
		return "victory"
	if not player_alive:
		return "defeat"
	return ""

func end_battle(result: String) -> void:
	battle_ended.emit(result)
