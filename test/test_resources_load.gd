extends RefCounted

class_name TestResourcesLoad

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var required_assets := [
		{ "path": "res://assets/sprites/tiles/tile_plain.png", "min_size": 100 },
		{ "path": "res://assets/sprites/tiles/tile_forest.png", "min_size": 100 },
		{ "path": "res://assets/sprites/tiles/tile_mountain.png", "min_size": 100 },
		{ "path": "res://assets/sprites/units/sprite_hero_001.png", "min_size": 200 },
		{ "path": "res://assets/sprites/units/sprite_hero_002.png", "min_size": 200 },
		{ "path": "res://assets/sprites/units/sprite_enemy_001.png", "min_size": 200 },
		{ "path": "res://assets/sprites/units/sprite_enemy_002.png", "min_size": 200 },
		{ "path": "res://assets/sprites/ui/ui_cursor.png", "min_size": 200 },
		{ "path": "res://assets/sprites/ui/ui_highlight_move.png", "min_size": 100 },
		{ "path": "res://assets/sprites/ui/ui_highlight_attack.png", "min_size": 100 },
		{ "path": "res://assets/sprites/ui/ui_highlight_heal.png", "min_size": 100 },
		{ "path": "res://assets/sprites/ui/ui_panel_bg.png", "min_size": 50 },
		{ "path": "res://assets/sprites/ui/ui_button_normal.png", "min_size": 50 },
		{ "path": "res://assets/sprites/ui/ui_button_hover.png", "min_size": 50 },
		{ "path": "res://assets/sprites/ui/ui_button_pressed.png", "min_size": 50 },
		{ "path": "res://assets/sprites/ui/ui_icon_hp.png", "min_size": 50 },
		{ "path": "res://assets/sprites/ui/ui_icon_mp.png", "min_size": 50 },
		{ "path": "res://assets/sprites/ui/ui_logo.png", "min_size": 500 },
		{ "path": "res://assets/sprites/ui/ui_arrow_continue.png", "min_size": 50 },
		{ "path": "res://assets/vfx/vfx_hit.png", "min_size": 100 },
		{ "path": "res://assets/vfx/vfx_heal.png", "min_size": 100 },
		{ "path": "res://assets/vfx/vfx_death.png", "min_size": 100 },
	]

	for asset in required_assets:
		var file := FileAccess.open(asset.path, FileAccess.READ)
		if not file:
			details.append("MISSING: %s" % asset.path)
			all_pass = false
		else:
			var size := file.get_length()
			if size < asset.min_size:
				details.append("TOO SMALL: %s (%d bytes, min %d)" % [asset.path, size, asset.min_size])
				all_pass = false
			else:
				details.append("OK: %s (%d bytes)" % [asset.path, size])

	return {
		"passed": all_pass,
		"message": "Resource loading %s" % ["passed" if all_pass else "failed"],
		"details": details.filter(func(d): return not d.begins_with("OK"))
	}
