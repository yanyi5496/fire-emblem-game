extends RefCounted

class_name TestPathfindingService

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true
	var service = preload("res://scripts/battle/pathfinding_service.gd").new()
	var tile_map := TileMap.new()

	var same_path: Array[Vector2i] = service.find_path(Vector2i(1, 1), Vector2i(1, 1), tile_map)
	if same_path.size() == 1 and same_path[0] == Vector2i(1, 1):
		details.append("PASS: same-position path returns single node")
	else:
		details.append("FAIL: same-position path should return [from]")
		all_pass = false

	var open_path: Array[Vector2i] = service.find_path(Vector2i(0, 0), Vector2i(2, 1), tile_map)
	if open_path.size() == 4 and open_path[0] == Vector2i(0, 0) and open_path[open_path.size() - 1] == Vector2i(2, 1):
		details.append("PASS: open-field path builds step-by-step route")
	else:
		details.append("FAIL: open-field path expected 4 nodes from (0,0) to (2,1), got %d" % open_path.size())
		all_pass = false

	return {
		"passed": all_pass,
		"message": "Pathfinding service %s" % ["passed" if all_pass else "failed"],
		"details": details,
	}
