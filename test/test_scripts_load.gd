extends RefCounted

class_name TestScriptsLoad

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var script_paths := [
		"res://scripts/autoload/data_manager.gd",
		"res://scripts/autoload/game_state.gd",
		"res://scripts/autoload/scene_router.gd",
		"res://scripts/autoload/save_manager.gd",
		"res://scripts/autoload/audio_manager.gd",
		"res://scripts/autoload/input_manager.gd",
		"res://scripts/battle/battle_controller.gd",
		"res://scripts/battle/turn_manager.gd",
		"res://scripts/battle/combat_manager.gd",
		"res://scripts/battle/pathfinding_service.gd",
		"res://scripts/battle/ai_controller.gd",
		"res://scripts/unit/unit_actor.gd",
		"res://scripts/unit/unit_runtime_state.gd",
		"res://scripts/unit/status_effect_service.gd",
		"res://scripts/ui/battle_hud.gd",
		"res://scripts/ui/action_menu.gd",
		"res://scripts/ui/attack_preview.gd",
		"res://scripts/ui/tile_info_panel.gd",
		"res://scripts/story/story_parser.gd",
		"res://scripts/story/story_player.gd",
		"res://scripts/menu/main_menu.gd",
		"res://scripts/menu/settings_menu.gd",
		"res://scripts/menu/save_load_menu.gd",
		"res://scripts/common/utils.gd",
		"res://test/test_game_state_flow.gd",
	]

	for sp in script_paths:
		var script := load(sp) as GDScript
		if not script:
			details.append("FAILED to load: %s" % sp)
			all_pass = false
		else:
			details.append("OK: %s" % sp)

	return {
		"passed": all_pass,
		"message": "%d/%d scripts loaded" % [details.filter(func(d): return d.begins_with("OK")).size(), script_paths.size()],
		"details": details.filter(func(d): return d.begins_with("FAIL"))
	}
