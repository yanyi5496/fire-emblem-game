extends Node

class_name PathfindingService

var battle_query = null

func _ready() -> void:
	if get_parent() and get_parent().has_node("BattleQueryService"):
		battle_query = get_parent().get_node("BattleQueryService")

func get_reachable_tiles(from: Vector2i, move_range: int, tile_map: TileMap) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var frontier: Array[Dictionary] = [{ "pos": from, "cost": 0 }]
	var best_cost := { from: 0 }
	while not frontier.is_empty():
		var current_index := _pop_lowest_cost(frontier)
		var current: Dictionary = frontier[current_index]
		frontier.remove_at(current_index)
		var current_pos: Vector2i = current.get("pos", from)
		var current_cost: int = int(current.get("cost", 0))
		if current_cost > move_range:
			continue
		if current_pos not in result:
			result.append(current_pos)
		for neighbor in _get_neighbors(current_pos):
			var move_cost := _get_move_cost(neighbor, tile_map)
			if move_cost < 0:
				continue
			var new_cost := current_cost + move_cost
			if new_cost > move_range:
				continue
			if not best_cost.has(neighbor) or new_cost < int(best_cost[neighbor]):
				best_cost[neighbor] = new_cost
				frontier.append({ "pos": neighbor, "cost": new_cost })
	return result

func find_path(from: Vector2i, to: Vector2i, tile_map: TileMap) -> Array[Vector2i]:
	if from == to:
		return [from]
	var frontier: Array[Dictionary] = [{ "pos": from, "cost": 0 }]
	var came_from := { from: from }
	var cost_so_far := { from: 0 }
	while not frontier.is_empty():
		var current_index := _pop_lowest_cost(frontier)
		var current: Dictionary = frontier[current_index]
		frontier.remove_at(current_index)
		var current_pos: Vector2i = current.get("pos", from)
		if current_pos == to:
			break
		for neighbor in _get_neighbors(current_pos):
			if not _can_step_on(tile_map, neighbor, to):
				continue
			var move_cost := _get_move_cost(neighbor, tile_map)
			if move_cost < 0:
				continue
			var new_cost: int = int(cost_so_far.get(current_pos, 0)) + move_cost
			if not cost_so_far.has(neighbor) or new_cost < int(cost_so_far[neighbor]):
				cost_so_far[neighbor] = new_cost
				came_from[neighbor] = current_pos
				frontier.append({ "pos": neighbor, "cost": new_cost })
	if not came_from.has(to):
		return [from]
	return _reconstruct_path(came_from, from, to)

func get_attack_range(from: Vector2i, min_range: int, max_range: int, tile_map: TileMap) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dx in range(-max_range, max_range + 1):
		for dy in range(-max_range, max_range + 1):
			var dist = abs(dx) + abs(dy)
			if dist >= min_range and dist <= max_range:
				result.append(Vector2i(from.x + dx, from.y + dy))
	return result

func _get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(pos.x + 1, pos.y),
		Vector2i(pos.x - 1, pos.y),
		Vector2i(pos.x, pos.y + 1),
		Vector2i(pos.x, pos.y - 1),
	]

func _get_move_cost(pos: Vector2i, tile_map: TileMap) -> int:
	var tile_data := tile_map.get_cell_tile_data(0, pos)
	if tile_data:
		var cost = tile_data.get_custom_data("move_cost")
		if cost != null:
			return cost
	var terrain_data := _get_runtime_terrain_data(tile_map, pos)
	if terrain_data.get("walkable", true) == false:
		return -1
	return int(terrain_data.get("move_cost", 1))

func _get_runtime_terrain_data(tile_map: TileMap, pos: Vector2i) -> Dictionary:
	if battle_query and battle_query.has_method("get_terrain_data_at"):
		return battle_query.get_terrain_data_at(pos)
	var scene = _get_battle_controller(tile_map)
	if scene and scene.has_method("get_terrain_data_at"):
		return scene.get_terrain_data_at(pos)
	return {}

func _can_step_on(tile_map: TileMap, pos: Vector2i, destination: Vector2i) -> bool:
	var terrain_data := _get_runtime_terrain_data(tile_map, pos)
	if not terrain_data.get("walkable", true):
		return false
	if pos == destination:
		return true
	var unit = _get_runtime_unit_at(tile_map, pos)
	return unit == null

func _get_runtime_unit_at(tile_map: TileMap, pos: Vector2i):
	if battle_query and battle_query.has_method("get_unit_at"):
		return battle_query.get_unit_at(pos)
	var scene = _get_battle_controller(tile_map)
	if scene and scene.has_method("get_unit_at"):
		return scene.get_unit_at(pos)
	return null

func _get_battle_controller(tile_map: TileMap):
	if not tile_map or not tile_map.is_inside_tree():
		return null
	return tile_map.get_tree().current_scene

func _pop_lowest_cost(frontier: Array[Dictionary]) -> int:
	var best_index := 0
	var best_cost: int = int(frontier[0].get("cost", 0))
	for i in range(1, frontier.size()):
		var cost: int = int(frontier[i].get("cost", 0))
		if cost < best_cost:
			best_cost = cost
			best_index = i
	return best_index

func _reconstruct_path(came_from: Dictionary, origin: Vector2i, destination: Vector2i) -> Array[Vector2i]:
	var current: Vector2i = destination
	var path: Array[Vector2i] = [destination]
	while current != origin:
		current = came_from.get(current, origin)
		path.push_front(current)
		if path.size() > 1024:
			break
	return path
