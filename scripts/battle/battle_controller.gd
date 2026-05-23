extends Node

class_name BattleController

const _combat_dep := preload("res://scripts/battle/combat_manager.gd")
const _unit_actor_dep := preload("res://scripts/unit/unit_actor.gd")
const _turn_mgr_dep := preload("res://scripts/battle/turn_manager.gd")
const _pathfind_dep := preload("res://scripts/battle/pathfinding_service.gd")
const _urs_dep := preload("res://scripts/unit/unit_runtime_state.gd")

signal battle_started()
signal battle_ended(result: String)
signal unit_selected(unit: Node)
signal action_executed(action: String)

enum BattleInteractionState { IDLE, UNIT_SELECTED, MOVING, ACTION_MENU, TARGETING, ATTACK_PREVIEW }

var combat_manager
var interaction_state: BattleInteractionState = BattleInteractionState.IDLE
var selected_unit = null
var movement_tiles: Array[Vector2i] = []
var attack_targets: Array = []
var pending_target = null
var pending_combat_result: Dictionary = {}
var battle_hud: Node = null

@onready var turn_manager = $TurnManager
@onready var cursor: Node2D = $Cursor
@onready var units_container: Node2D = $Units
@onready var tile_map: TileMap = $MapRoot/GroundTileMap
@onready var highlight_tile_map: TileMap = $MapRoot/HighlightTileMap
@onready var pathfinding = $PathfindingService

var map_data: Dictionary = {}
var _battle_started_once := false

func _ready() -> void:
	combat_manager = _combat_dep.new()
	if not InputManager.confirm_pressed.is_connected(_on_confirm):
		InputManager.confirm_pressed.connect(_on_confirm)
	if not InputManager.cancel_pressed.is_connected(_on_cancel):
		InputManager.cancel_pressed.connect(_on_cancel)
	if not InputManager.move_cursor.is_connected(_on_move_cursor):
		InputManager.move_cursor.connect(_on_move_cursor)
	battle_hud = $UI if has_node("UI") else null
	if battle_hud:
		if not battle_hud.end_turn_pressed.is_connected(_on_end_turn_pressed):
			battle_hud.end_turn_pressed.connect(_on_end_turn_pressed)
		var action_menu_node = battle_hud.get_node("ActionMenu") if battle_hud.has_node("ActionMenu") else null
		if action_menu_node:
			if not action_menu_node.move_selected.is_connected(_on_action_move):
				action_menu_node.move_selected.connect(_on_action_move)
			if not action_menu_node.attack_selected.is_connected(_on_action_attack):
				action_menu_node.attack_selected.connect(_on_action_attack)
			if not action_menu_node.wait_selected.is_connected(_on_action_wait):
				action_menu_node.wait_selected.connect(_on_action_wait)
		var preview_node = battle_hud.get_node("AttackPreview") if battle_hud.has_node("AttackPreview") else null
		if preview_node:
			if not preview_node.attack_confirmed.is_connected(_on_attack_confirmed):
				preview_node.attack_confirmed.connect(_on_attack_confirmed)
			if not preview_node.attack_cancelled.is_connected(_on_attack_cancelled):
				preview_node.attack_cancelled.connect(_on_attack_cancelled)
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
	if not turn_manager.turn_started.is_connected(_on_turn_started):
		turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.start_turn("player")
	battle_started.emit()

func _on_turn_started(phase: String) -> void:
	if battle_hud and battle_hud.has_method("update_turn_info"):
		battle_hud.update_turn_info(phase, turn_manager.turn_number)

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

func _on_move_cursor(direction: Vector2) -> void:
	if interaction_state in [BattleInteractionState.IDLE, BattleInteractionState.UNIT_SELECTED, BattleInteractionState.MOVING, BattleInteractionState.TARGETING]:
		var new_pos := Vector2i(cursor.position.x / 64 + int(direction.x), cursor.position.y / 64 + int(direction.y))
		new_pos.x = clampi(new_pos.x, 0, map_data.get("width", 10) - 1)
		new_pos.y = clampi(new_pos.y, 0, map_data.get("height", 10) - 1)
		cursor.position = Vector2(new_pos.x * 64, new_pos.y * 64)

func _on_confirm() -> void:
	match interaction_state:
		BattleInteractionState.IDLE:
			_try_select_unit()
		BattleInteractionState.UNIT_SELECTED, BattleInteractionState.MOVING:
			_start_movement()
		BattleInteractionState.ACTION_MENU:
			pass
		BattleInteractionState.TARGETING:
			_try_attack_target()

func _on_cancel() -> void:
	match interaction_state:
		BattleInteractionState.UNIT_SELECTED:
			_deselect_unit()
		BattleInteractionState.MOVING:
			_cancel_movement()
		BattleInteractionState.ACTION_MENU:
			_cancel_to_unit_select()
		BattleInteractionState.TARGETING:
			_cancel_targeting()
		BattleInteractionState.ATTACK_PREVIEW:
			_cancel_attack_preview()

func _try_select_unit() -> void:
	var cursor_pos := Vector2i(cursor.position.x / 64, cursor.position.y / 64)
	for unit in units_container.get_children():
		if unit.grid_pos == cursor_pos and unit.is_alive() and unit.can_move() and unit.team == "player":
			selected_unit = unit
			interaction_state = BattleInteractionState.UNIT_SELECTED
			unit_selected.emit(unit)
			_show_movement_range(unit)
			return

func _deselect_unit() -> void:
	selected_unit = null
	interaction_state = BattleInteractionState.IDLE
	_clear_highlights()

func _show_movement_range(unit) -> void:
	var move_range: int = unit.runtime_state.mov_stat
	movement_tiles = pathfinding.get_reachable_tiles(unit.grid_pos, move_range, tile_map)
	_highlight_tiles(movement_tiles)

func _highlight_tiles(tiles: Array[Vector2i]) -> void:
	if not highlight_tile_map:
		return
	highlight_tile_map.clear()
	for tile in tiles:
		highlight_tile_map.set_cell(0, tile, 0, Vector2i(1, 0))

func _clear_highlights() -> void:
	if highlight_tile_map:
		highlight_tile_map.clear()
	movement_tiles.clear()
	attack_targets.clear()

func _start_movement() -> void:
	var target_pos := Vector2i(cursor.position.x / 64, cursor.position.y / 64)
	if target_pos not in movement_tiles:
		return
	selected_unit.grid_pos = target_pos
	selected_unit.position = Vector2(target_pos.x * 64, target_pos.y * 64)
	selected_unit.runtime_state.action_state = _urs_dep.ActionState.MOVED
	_clear_highlights()
	interaction_state = BattleInteractionState.ACTION_MENU
	if battle_hud and battle_hud.has_method("show_action_menu"):
		battle_hud.show_action_menu()

func _cancel_movement() -> void:
	_clear_highlights()
	interaction_state = BattleInteractionState.ACTION_MENU

func _cancel_to_unit_select() -> void:
	interaction_state = BattleInteractionState.UNIT_SELECTED
	_show_movement_range(selected_unit)

func _try_attack_target() -> void:
	var cursor_pos := Vector2i(cursor.position.x / 64, cursor.position.y / 64)
	for target in attack_targets:
		if target.grid_pos == cursor_pos:
			var weapon_id: String = selected_unit.runtime_state.equipped_weapon
			if weapon_id == "":
				return
			pending_target = target
			pending_combat_result = combat_manager.simulate(selected_unit, target, weapon_id)
			interaction_state = BattleInteractionState.ATTACK_PREVIEW
			if battle_hud and battle_hud.has_method("show_attack_preview"):
				battle_hud.show_attack_preview(pending_combat_result)
			return

func _cancel_targeting() -> void:
	interaction_state = BattleInteractionState.ACTION_MENU
	_clear_highlights()

func _cancel_attack_preview() -> void:
	interaction_state = BattleInteractionState.TARGETING

func _on_action_move() -> void:
	interaction_state = BattleInteractionState.MOVING
	_show_movement_range(selected_unit)

func _on_action_attack() -> void:
	interaction_state = BattleInteractionState.TARGETING
	attack_targets = _get_enemies_in_range(selected_unit)
	for target in attack_targets:
		var tiles: Array[Vector2i] = [target.grid_pos]
		_highlight_tiles(tiles)

func _on_action_wait() -> void:
	selected_unit.wait()
	_execute_action_complete()

func _on_attack_confirmed() -> void:
	if not selected_unit or not pending_target:
		return
	var weapon_id: String = selected_unit.runtime_state.equipped_weapon
	if weapon_id == "":
		return
	var target: Node = pending_target
	interaction_state = BattleInteractionState.IDLE
	selected_unit.attack(target)
	combat_manager.execute(selected_unit, target, weapon_id)
	_clear_highlights()
	attack_targets.clear()
	pending_target = null
	pending_combat_result = {}
	selected_unit = null
	if battle_hud and battle_hud.has_method("hide_attack_preview"):
		battle_hud.hide_attack_preview()
	_check_battle_end()

func _on_attack_cancelled() -> void:
	interaction_state = BattleInteractionState.TARGETING
	if battle_hud and battle_hud.has_method("hide_attack_preview"):
		battle_hud.hide_attack_preview()

func _execute_action_complete() -> void:
	_clear_highlights()
	interaction_state = BattleInteractionState.IDLE
	selected_unit = null
	_check_battle_end()
	if battle_hud and battle_hud.has_method("hide_action_menu"):
		battle_hud.hide_action_menu()

func _get_enemies_in_range(unit) -> Array:
	var result: Array = []
	var weapon_data: Dictionary = DataManager.get_weapon(unit.runtime_state.equipped_weapon)
	if weapon_data.is_empty():
		return result
	var min_range: int = weapon_data.get("min_range", 1)
	var max_range: int = weapon_data.get("max_range", 1)
	var attack_tiles: Array[Vector2i] = pathfinding.get_attack_range(unit.grid_pos, min_range, max_range, tile_map)
	for attack_tile in attack_tiles:
		var enemy = get_unit_at(attack_tile)
		if enemy and enemy.team != unit.team and enemy.is_alive():
			result.append(enemy)
	return result

func on_unit_clicked(unit: Node) -> void:
	unit_selected.emit(unit)

func get_unit_at(pos: Vector2i):
	for unit in units_container.get_children():
		if unit.grid_pos == pos and unit.is_alive():
			return unit
	return null

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

func _on_end_turn_pressed() -> void:
	interaction_state = BattleInteractionState.IDLE
	_clear_highlights()
	if battle_hud and battle_hud.has_method("hide_action_menu"):
		battle_hud.hide_action_menu()
	selected_unit = null
	turn_manager.end_turn()

func _check_battle_end() -> void:
	var result := check_victory_condition()
	if result != "":
		end_battle(result)

func end_battle(result: String) -> void:
	GameState.set_phase(GameState.GamePhase.BATTLE_RESULT)
	battle_ended.emit(result)
	SceneRouter.goto("result")
