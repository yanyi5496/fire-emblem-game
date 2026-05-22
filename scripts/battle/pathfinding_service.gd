extends Node

class_name PathfindingService

func get_reachable_tiles(from: Vector2i, move_range: int, tile_map: TileMap) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var visited := {}
	var queue := [{ "pos": from, "cost": 0 }]
	visited[from] = true
	var index := 0
	while index < queue.size():
		var current = queue[index]
		index += 1
		result.append(current.pos)
		for neighbor in _get_neighbors(current.pos):
			if visited.has(neighbor):
				continue
			var move_cost := _get_move_cost(neighbor, tile_map)
			if move_cost < 0:
				continue
			var new_cost := current.cost + move_cost
			if new_cost > move_range:
				continue
			visited[neighbor] = true
			queue.append({ "pos": neighbor, "cost": new_cost })
	return result

func find_path(from: Vector2i, to: Vector2i, tile_map: TileMap) -> Array[Vector2i]:
	return [from, to]

func get_attack_range(from: Vector2i, min_range: int, max_range: int, tile_map: TileMap) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dx in range(-max_range, max_range + 1):
		for dy in range(-max_range, max_range + 1):
			var dist := abs(dx) + abs(dy)
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
	if not tile_data:
		return 1
	var cost := tile_data.get_custom_data("move_cost")
	if cost == null:
		return 1
	return cost
