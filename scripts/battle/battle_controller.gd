extends Node

class_name BattleController

const _combat_dep := preload("res://scripts/battle/combat_manager.gd")
const _unit_actor_dep := preload("res://scripts/unit/unit_actor.gd")
const _turn_mgr_dep := preload("res://scripts/battle/turn_manager.gd")
const _pathfind_dep := preload("res://scripts/battle/pathfinding_service.gd")
const _urs_dep := preload("res://scripts/unit/unit_runtime_state.gd")
const _query_dep := preload("res://scripts/battle/battle_query_service.gd")
const _victory_dep := preload("res://scripts/battle/victory_judge.gd")
const _skill_dep := preload("res://scripts/battle/battle_skill_service.gd")
const _lifecycle_dep := preload("res://scripts/battle/battle_lifecycle_service.gd")

signal battle_started()
signal battle_ended(result: String)
signal unit_selected(unit: Node)
signal action_executed(action: String)

enum BattleInteractionState { IDLE, UNIT_SELECTED, MOVING, ACTION_MENU, TARGETING, ATTACK_PREVIEW, SKILL_TARGETING }

var combat_manager
var interaction_state: BattleInteractionState = BattleInteractionState.IDLE
var selected_unit = null
var movement_tiles: Array[Vector2i] = []
var attack_targets: Array = []
var pending_target = null
var pending_combat_result: Dictionary = {}
var pending_skill_id: String = ""
var _available_skills: Array[String] = []
var _current_skill_index: int = 0
var battle_query: Node = null
var victory_judge = null
var battle_hud: Node = null
var skill_service = null
var battle_lifecycle = null

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
	battle_query = _query_dep.new()
	victory_judge = _victory_dep.new()
	skill_service = _skill_dep.new()
	battle_lifecycle = _lifecycle_dep.new()
	add_child(battle_query)
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
		if battle_hud.has_signal("save_pressed") and not battle_hud.save_pressed.is_connected(_on_save_pressed):
			battle_hud.save_pressed.connect(_on_save_pressed)
		var action_menu_node = battle_hud.get_node("ActionMenu") if battle_hud.has_node("ActionMenu") else null
		if action_menu_node:
			if not action_menu_node.move_selected.is_connected(_on_action_move):
				action_menu_node.move_selected.connect(_on_action_move)
			if not action_menu_node.attack_selected.is_connected(_on_action_attack):
				action_menu_node.attack_selected.connect(_on_action_attack)
			if not action_menu_node.skill_selected.is_connected(_on_action_skill):
				action_menu_node.skill_selected.connect(_on_action_skill)
			if not action_menu_node.wait_selected.is_connected(_on_action_wait):
				action_menu_node.wait_selected.connect(_on_action_wait)
			if not action_menu_node.switch_weapon_selected.is_connected(_on_action_switch_weapon):
				action_menu_node.switch_weapon_selected.connect(_on_action_switch_weapon)
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
	_apply_map_data()
	_spawn_units()
	if battle_query:
		battle_query.units_container = units_container
		battle_query.pathfinding = pathfinding
		battle_query.tile_map = tile_map
		battle_query.map_data = map_data
	if victory_judge:
		victory_judge.setup(map_data)
	turn_manager.initialize_battle(GameState.turn_number)
	if not turn_manager.turn_started.is_connected(_on_turn_started):
		turn_manager.turn_started.connect(_on_turn_started)
	if not turn_manager.round_ended.is_connected(_on_round_ended):
		turn_manager.round_ended.connect(_on_round_ended)
	if not turn_manager.battle_check_requested.is_connected(_on_battle_check_requested):
		turn_manager.battle_check_requested.connect(_on_battle_check_requested)
	if not turn_manager.checkpoint_requested.is_connected(_on_checkpoint_requested):
		turn_manager.checkpoint_requested.connect(_on_checkpoint_requested)
	cursor.position = Vector2.ZERO
	_update_tile_info(Vector2i.ZERO)
	if battle_hud:
		battle_hud.update_turn_info("player", turn_manager.turn_number)
	turn_manager.start_turn("player")
	battle_started.emit()

func _on_turn_started(phase: String) -> void:
	if battle_hud and battle_hud.has_method("update_turn_info"):
		battle_hud.update_turn_info(phase, turn_manager.turn_number)
	if phase == "player":
		_check_battle_end()

func _on_round_ended() -> void:
	_check_battle_end()

func _on_battle_check_requested() -> void:
	_check_battle_end()

func _spawn_units() -> void:
	var spawn_units: Array = _get_spawn_unit_data()
	if spawn_units.is_empty():
		return
	for u in spawn_units:
		_spawn_unit(u)

func _get_spawn_unit_data() -> Array:
	if GameState.current_map_id == map_data.get("id", "") and not GameState.battle_units.is_empty():
		var snapshot_map_id: String = str(GameState.battle_map_state.get("map_id", ""))
		if snapshot_map_id == GameState.current_map_id:
			return GameState.battle_units
	return map_data.get("units", [])

func _spawn_unit(data: Dictionary) -> void:
	var unit_scene := preload("res://scenes/battle/unit/unit.tscn")
	var unit := unit_scene.instantiate()
	unit.setup(
		data.get("unit_id", ""),
		data.get("team", ""),
		Vector2i(data.get("x", 0), data.get("y", 0))
	)
	if data.has("current_hp"):
		unit.apply_saved_state(data)
	if unit.runtime_state:
		unit.runtime_state.ai_type = str(data.get("ai_type", "aggressive"))
	units_container.add_child(unit)

func _on_move_cursor(direction: Vector2) -> void:
	if interaction_state in [BattleInteractionState.IDLE, BattleInteractionState.UNIT_SELECTED, BattleInteractionState.MOVING, BattleInteractionState.TARGETING, BattleInteractionState.SKILL_TARGETING]:
		var new_pos := Vector2i(cursor.position.x / 64 + int(direction.x), cursor.position.y / 64 + int(direction.y))
		new_pos.x = clampi(new_pos.x, 0, map_data.get("width", 10) - 1)
		new_pos.y = clampi(new_pos.y, 0, map_data.get("height", 10) - 1)
		cursor.position = Vector2(new_pos.x * 64, new_pos.y * 64)
		_update_tile_info(new_pos)

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
		BattleInteractionState.SKILL_TARGETING:
			_try_skill_target()

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
		BattleInteractionState.SKILL_TARGETING:
			_cancel_skill_targeting()

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
	var occupied_unit = get_unit_at(target_pos)
	if occupied_unit and occupied_unit != selected_unit:
		return
	move_unit_to(selected_unit, target_pos)
	_clear_highlights()
	interaction_state = BattleInteractionState.ACTION_MENU
	if battle_hud and battle_hud.has_method("show_action_menu_for"):
		battle_hud.show_action_menu_for(selected_unit)
	elif battle_hud and battle_hud.has_method("show_action_menu"):
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
	var weapon_id: String = selected_unit.runtime_state.equipped_weapon
	if weapon_id == "" or selected_unit.runtime_state.is_weapon_broken(weapon_id):
		if battle_hud and battle_hud.has_method("show_status_message"):
			battle_hud.show_status_message("武器已损坏")
		return
	interaction_state = BattleInteractionState.TARGETING
	attack_targets = get_enemies_in_range(selected_unit)
	var tiles: Array[Vector2i] = []
	for target in attack_targets:
		tiles.append(target.grid_pos)
	_highlight_tiles(tiles)

func _on_action_skill() -> void:
	if not selected_unit:
		return
	_available_skills = skill_service.get_available_skills(selected_unit)
	if _available_skills.is_empty():
		return
	_current_skill_index = 0
	_activate_skill(_available_skills[0])

func _activate_skill(skill_id: String) -> void:
	pending_skill_id = skill_id
	var target_group: String = skill_service.get_target_group(skill_id)
	if target_group == "self":
		var self_result: Dictionary = skill_service.execute_skill(selected_unit, selected_unit, skill_id)
		_finish_skill_action(self_result)
		return
	interaction_state = BattleInteractionState.SKILL_TARGETING
	var tiles: Array[Vector2i] = skill_service.get_target_tiles(
		selected_unit,
		skill_id,
		battle_query,
		pathfinding,
		tile_map
	)
	_highlight_tiles(tiles)

func _on_action_wait() -> void:
	selected_unit.wait()
	_execute_action_complete()

func _on_action_switch_weapon() -> void:
	if not selected_unit or not selected_unit.runtime_state:
		return
	var inv: Array[String] = selected_unit.runtime_state.inventory
	if inv.size() <= 1:
		return
	var current: String = selected_unit.runtime_state.equipped_weapon
	var idx: int = inv.find(current)
	var next_idx: int = (idx + 1) % inv.size()
	selected_unit.runtime_state.equipped_weapon = inv[next_idx]
	selected_unit.runtime_state.get_weapon_durability(inv[next_idx])
	if battle_hud and battle_hud.has_method("show_message"):
		battle_hud.show_message("装备: %s" % DataManager.get_weapon(inv[next_idx]).get("name", inv[next_idx]))
	_execute_action_complete()

func _on_attack_confirmed() -> void:
	if not selected_unit or not pending_target:
		return
	var weapon_id: String = selected_unit.runtime_state.equipped_weapon
	if weapon_id == "":
		return
	var target: Node = pending_target
	interaction_state = BattleInteractionState.IDLE
	skill_service.apply_unit_passives(selected_unit, "before_combat")
	skill_service.apply_unit_passives(target, "before_combat")
	selected_unit.attack(target)
	combat_manager.execute(selected_unit, target, weapon_id, skill_service)
	_distribute_combat_exp(selected_unit, target)
	skill_service.apply_unit_passives(selected_unit, "after_combat")
	skill_service.apply_unit_passives(target, "after_combat")
	skill_service.clear_temporary_passives(selected_unit)
	skill_service.clear_temporary_passives(target)
	_clear_highlights()
	attack_targets.clear()
	pending_target = null
	pending_combat_result = {}
	selected_unit = null
	if battle_hud and battle_hud.has_method("hide_attack_preview"):
		battle_hud.hide_attack_preview()
	_process_level_ups()
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

func get_enemies_in_range(unit) -> Array:
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

func get_skill_range(unit, skill_id: String) -> Vector2i:
	return skill_service.get_skill_range(unit, skill_id)

func get_skill_range_targets(unit, skill_id: String, target_group: String) -> Array:
	var result: Array = skill_service.get_skill_targets(unit, skill_id, battle_query, pathfinding, tile_map)
	if target_group == "":
		return result
	return result.filter(
		func(target): return (
			(target_group == "ally" and target.team == unit.team) or
			(target_group == "enemy" and target.team != unit.team) or
			(target_group == "self" and target == unit)
		)
	)

func _try_skill_target() -> void:
	var cursor_pos := Vector2i(cursor.position.x / 64, cursor.position.y / 64)
	var target = get_unit_at(cursor_pos)
	if not target:
		return
	if pending_skill_id == "" or not selected_unit:
		return
	var result: Dictionary = skill_service.execute_skill(selected_unit, target, pending_skill_id)
	if not result.get("success", false):
		return
	_finish_skill_action(result)

func _cancel_skill_targeting() -> void:
	interaction_state = BattleInteractionState.ACTION_MENU
	_clear_highlights()

func _finish_skill_action(result: Dictionary) -> void:
	_clear_highlights()
	pending_skill_id = ""
	pending_target = null
	interaction_state = BattleInteractionState.IDLE
	if result.get("success", false):
		action_executed.emit(str(result.get("action", "skill")))
		if battle_hud and battle_hud.has_method("show_status_message"):
			battle_hud.show_status_message(str(result.get("message", "")))
	selected_unit = null
	_check_battle_end()
	if battle_hud and battle_hud.has_method("hide_action_menu"):
		battle_hud.hide_action_menu()

func get_unit_at(pos: Vector2i):
	if battle_query:
		return battle_query.get_unit_at(pos)
	return null

func check_victory_condition() -> String:
	if not victory_judge:
		return ""
	var player_alive := false
	var enemy_alive := false
	var lord_id: String = str(map_data.get("lord_unit_id", ""))
	var lord_alive := lord_id == ""
	var escape_points: Array = map_data.get("escape_points", [])
	var lord_on_escape := false
	var all_on_escape := false
	var escape_count := 0
	for unit in units_container.get_children():
		if lord_id != "" and unit.runtime_state and unit.runtime_state.template_id == lord_id:
			lord_alive = unit.is_alive()
		if unit.is_alive():
			match unit.team:
				"player":
					player_alive = true
					if not escape_points.is_empty() and unit.grid_pos in escape_points:
						escape_count += 1
						if lord_id != "" and unit.runtime_state and unit.runtime_state.template_id == lord_id:
							lord_on_escape = true
				"enemy": enemy_alive = true
	if not escape_points.is_empty() and escape_count > 0:
		var player_unit_count := 0
		for unit in units_container.get_children():
			if unit.is_alive() and unit.team == "player":
				player_unit_count += 1
		all_on_escape = escape_count >= player_unit_count
	return victory_judge.check_victory(enemy_alive, player_alive, turn_manager.turn_number, lord_alive, lord_on_escape, all_on_escape)

func has_battle_ended() -> bool:
	return check_victory_condition() != ""

func get_battle_result() -> String:
	return check_victory_condition()

func _distribute_combat_exp(attacker: Node, defender: Node) -> void:
	if not attacker.runtime_state or not defender.runtime_state:
		return
	var def_level: int = defender.runtime_state.level
	var exp_gain: int = def_level * 10 + 20
	if not defender.is_alive():
		exp_gain += 20
	var gained: Array[Dictionary] = attacker.runtime_state.gain_exp(exp_gain)
	for lu in gained:
		lu["unit_name"] = attacker.unit_id

func _distribute_victory_exp() -> void:
	for unit in units_container.get_children():
		if unit.is_alive() and unit.team == "player" and unit.runtime_state:
			var gained: Array[Dictionary] = unit.runtime_state.gain_exp(5)
			for lu in gained:
				lu["unit_name"] = unit.unit_id

func _process_level_ups() -> void:
	for unit in units_container.get_children():
		if unit.runtime_state:
			var pending: Array[Dictionary] = unit.runtime_state.pending_level_ups
			if not pending.is_empty():
				unit.runtime_state.pending_level_ups = []

func _check_battle_end() -> bool:
	var result := check_victory_condition()
	if result != "":
		end_battle(result)
		return true
	return false

func end_battle(result: String) -> void:
	if GameState.current_phase == GameState.GamePhase.BATTLE_RESULT:
		return
	if result == "victory":
		_distribute_victory_exp()
	_process_level_ups()
	battle_lifecycle.finalize_battle(
		result,
		units_container,
		turn_manager.turn_number,
		GameState.current_map_id,
		GameState.current_chapter
	)
	battle_ended.emit(result)
	SceneRouter.goto("result")

func _on_end_turn_pressed() -> void:
	interaction_state = BattleInteractionState.IDLE
	_clear_highlights()
	if battle_hud and battle_hud.has_method("hide_action_menu"):
		battle_hud.hide_action_menu()
	selected_unit = null
	turn_manager.end_turn()

func move_unit_to(unit: Node, target_pos: Vector2i) -> void:
	if not unit:
		return
	unit.grid_pos = target_pos
	unit.position = Vector2(target_pos.x * 64, target_pos.y * 64)
	if unit.runtime_state and unit.runtime_state.action_state == _urs_dep.ActionState.IDLE:
		unit.runtime_state.action_state = _urs_dep.ActionState.MOVED

func get_enemy_units_for(unit: Node) -> Array:
	if battle_query:
		return battle_query.get_enemy_units_for(unit)
	return []

func get_walkable_tiles_for(unit: Node) -> Array[Vector2i]:
	if battle_query:
		return battle_query.get_walkable_tiles_for(unit)
	return []

func get_terrain_id_at(pos: Vector2i) -> String:
	if battle_query:
		return battle_query.get_terrain_id_at(pos)
	return "plain"

func get_terrain_data_at(pos: Vector2i) -> Dictionary:
	if battle_query:
		return battle_query.get_terrain_data_at(pos)
	return {}

func is_tile_walkable(pos: Vector2i) -> bool:
	if battle_query:
		return battle_query.is_tile_walkable(pos)
	return true

func get_distance(a: Vector2i, b: Vector2i) -> int:
	if battle_query:
		return battle_query.get_distance(a, b)
	return abs(a.x - b.x) + abs(a.y - b.y)

func _apply_map_data() -> void:
	if not tile_map:
		return
	var width: int = map_data.get("width", 0)
	var height: int = map_data.get("height", 0)
	var tiles: Array = map_data.get("tiles", [])
	tile_map.clear()
	if tile_map.tile_set == null:
		_update_tile_info(Vector2i.ZERO)
		return
	for y in range(min(height, tiles.size())):
		var row: Array = tiles[y]
		for x in range(min(width, row.size())):
			var atlas_x := max(0, int(row[x]) - 1)
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(atlas_x, 0))
	_update_tile_info(Vector2i.ZERO)

func _update_tile_info(pos: Vector2i) -> void:
	if not battle_hud:
		return
	var tile_info_panel = battle_hud.get_node("TileInfoPanel") if battle_hud.has_node("TileInfoPanel") else null
	if tile_info_panel and tile_info_panel.has_method("show_tile_info"):
		tile_info_panel.show_tile_info(get_terrain_id_at(pos), get_terrain_data_at(pos))

func _on_save_pressed() -> void:
	if battle_lifecycle.save_checkpoint(1, units_container, turn_manager.turn_number, GameState.current_map_id) and battle_hud and battle_hud.has_method("show_save_feedback"):
		battle_hud.show_save_feedback(turn_manager.turn_number, _current_phase_text())

func _on_checkpoint_requested(slot: int) -> void:
	battle_lifecycle.save_checkpoint(slot, units_container, turn_manager.turn_number, GameState.current_map_id)

func _current_phase_text() -> String:
	match int(turn_manager.current_phase):
		0:
			return "玩家"
		1:
			return "敌方"
		2:
			return "友方"
		_:
			return "当前"

func build_save_snapshot() -> Dictionary:
	return battle_lifecycle.build_snapshot(units_container, turn_manager.turn_number, GameState.current_map_id)
