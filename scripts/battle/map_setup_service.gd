extends RefCounted

class_name MapSetupService

const TILE_MARKER_ESCAPE := 3
const TILE_MARKER_CAPTURE := 4

func setup_tileset(tile_map: TileMap) -> void:
	if not tile_map:
		return
	if tile_map.tile_set != null:
		return
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(64, 64)
	var tile_paths := [
		"res://assets/sprites/tiles/tile_plain.png",
		"res://assets/sprites/tiles/tile_forest.png",
		"res://assets/sprites/tiles/tile_mountain.png",
		"res://assets/sprites/tiles/tile_escape.png",
		"res://assets/sprites/tiles/tile_capture.png",
	]
	for i in range(tile_paths.size()):
		var tex := load(tile_paths[i]) as Texture2D
		if tex:
			var atlas := TileSetAtlasSource.new()
			atlas.texture = tex
			atlas.texture_region_size = Vector2i(64, 64)
			atlas.create_tile(Vector2i(0, 0))
			tileset.add_source(atlas, i)
	tile_map.tile_set = tileset

func apply_map_data(tile_map: TileMap, map_data: Dictionary, update_callback: Callable) -> void:
	if not tile_map:
		return
	var width: int = map_data.get("width", 0)
	var height: int = map_data.get("height", 0)
	var tiles: Array = map_data.get("tiles", [])
	tile_map.clear()
	if tile_map.tile_set == null:
		update_callback.call(Vector2i.ZERO)
		return
	for y in range(min(height, tiles.size())):
		var row: Array = tiles[y]
		for x in range(min(width, row.size())):
			var tile_val := max(1, int(row[x]))
			tile_map.set_cell(0, Vector2i(x, y), tile_val - 1, Vector2i(0, 0))
	_apply_marker_tiles(tile_map, map_data)
	update_callback.call(Vector2i.ZERO)

func _apply_marker_tiles(tile_map: TileMap, map_data: Dictionary) -> void:
	var escape_points: Array = map_data.get("escape_points", [])
	for ep in escape_points:
		var pos: Vector2i = Vector2i(int(ep.get("x", 0)), int(ep.get("y", 0)))
		tile_map.set_cell(0, pos, TILE_MARKER_ESCAPE, Vector2i(0, 0))
	var capture_points: Array = map_data.get("capture_points", [])
	for cp in capture_points:
		var pos: Vector2i = Vector2i(int(cp.get("x", 0)), int(cp.get("y", 0)))
		tile_map.set_cell(0, pos, TILE_MARKER_CAPTURE, Vector2i(0, 0))
		return
	for y in range(min(height, tiles.size())):
		var row: Array = tiles[y]
		for x in range(min(width, row.size())):
			var tile_val := max(1, int(row[x]))
			tile_map.set_cell(0, Vector2i(x, y), tile_val - 1, Vector2i(0, 0))
	update_callback.call(Vector2i.ZERO)