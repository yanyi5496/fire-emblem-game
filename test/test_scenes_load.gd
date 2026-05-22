extends RefCounted

class_name TestScenesLoad

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var scene_paths := [
		"res://scenes/boot/boot_scene.tscn",
		"res://scenes/menu/main_menu.tscn",
		"res://scenes/menu/settings_menu.tscn",
		"res://scenes/menu/save_load_menu.tscn",
		"res://scenes/battle/battle_scene.tscn",
		"res://scenes/battle/cursor/battle_cursor.tscn",
		"res://scenes/battle/unit/unit.tscn",
		"res://scenes/battle/ui/battle_hud.tscn",
		"res://scenes/battle/ui/action_menu.tscn",
		"res://scenes/battle/ui/attack_preview.tscn",
		"res://scenes/battle/ui/tile_info_panel.tscn",
		"res://scenes/battle/effects/hit_effect.tscn",
		"res://scenes/battle/effects/crit_effect.tscn",
		"res://scenes/battle/effects/skill_effect.tscn",
		"res://scenes/story/story_player.tscn",
		"res://scenes/story/dialogue_box.tscn",
		"res://scenes/story/choice_box.tscn",
	]

	for sp in scene_paths:
		var packed := load(sp) as PackedScene
		if not packed:
			details.append("FAILED to load: %s" % sp)
			all_pass = false
		else:
			var can_instantiate := packed.can_instantiate()
			if can_instantiate:
				details.append("OK: %s" % sp)
			else:
				details.append("CANNOT INSTANTIATE: %s" % sp)
				all_pass = false

	return {
		"passed": all_pass,
		"message": "%d/%d scenes loaded" % [details.filter(func(d): return d.begins_with("OK")).size(), scene_paths.size()],
		"details": details.filter(func(d): return not d.begins_with("OK"))
	}
