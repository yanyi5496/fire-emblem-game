extends Node

class_name BattleQueryService

var units_container: Node2D = null
var pathfinding = null
var tile_map: TileMap = null
var map_data: Dictionary = {}

func get_unit_at(pos: Vector2i):
	if not units_container:
		return null
	for unit in units_container.get_children():
		if unit.grid_pos == pos and unit.is_alive():
			return unit
	return null

func get_enemy_units_for(unit: Node) -> Array:
	var result: Array = []
	if not units_container:
		return result
	for other in units_container.get_children():
		if other == unit:
			continue
		if other.team == unit.team:
			continue
		if not other.is_alive():
			continue
		result.append(other)
	return result

func get_walkable_tiles_for(unit: Node) -> Array[Vector2i]:
	if not pathfinding or not tile_map:
		return []
	var reachable: Array = pathfinding.get_reachable_tiles(unit.grid_pos, unit.runtime_state.mov_stat, tile_map)
	var result: Array[Vector2i] = []
	for tile in reachable:
		if not is_tile_walkable(tile):
			continue
		var occupied = get_unit_at(tile)
		if occupied and occupied != unit:
			continue
		result.append(tile)
	return result

func get_terrain_id_at(pos: Vector2i) -> String:
	var terrain_ids: Array = map_data.get("terrain_ids", [])
	if pos.y < 0 or pos.y >= terrain_ids.size():
		return "plain"
	var row: Array = terrain_ids[pos.y]
	if pos.x < 0 or pos.x >= row.size():
		return "plain"
	return str(row[pos.x])

func get_terrain_data_at(pos: Vector2i) -> Dictionary:
	var terrain_defs: Dictionary = map_data.get("terrain_defs", {})
	var terrain_id := get_terrain_id_at(pos)
	return terrain_defs.get(terrain_id, {
		"move_cost": 1,
		"avoid_bonus": 0,
		"defense_bonus": 0,
		"walkable": true,
		"height": 0,
	})

func is_tile_walkable(pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x >= map_data.get("width", 0) or pos.y >= map_data.get("height", 0):
		return false
	return bool(get_terrain_data_at(pos).get("walkable", true))

func get_distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)
