extends RefCounted

class_name TestScenesLoad

func run() -> Dictionary:
	var details: Array[String] = []
	var all_pass := true

	var scene_paths := [
		"res://scenes/boot/boot_scene.tscn",
		"res://scenes/menu/main_menu.tscn",
		"res://scenes/menu/battle_result_menu.tscn",
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
	var required_nodes := {
		"res://scenes/battle/battle_scene.tscn": [
			"MapRoot/GroundTileMap",
			"Units",
			"Cursor",
			"TurnManager",
			"PathfindingService",
			"UI",
		],
		"res://scenes/battle/unit/unit.tscn": [
			"Sprite2D",
			"AnimationPlayer",
		],
		"res://scenes/battle/ui/battle_hud.tscn": [
			"TurnLabel",
			"UnitInfoPanel",
			"ActionMenu",
			"AttackPreview",
		],
		"res://scenes/battle/ui/action_menu.tscn": [
			"VBoxContainer/MoveButton",
			"VBoxContainer/AttackButton",
			"VBoxContainer/SkillButton",
			"VBoxContainer/WaitButton",
		],
		"res://scenes/battle/ui/attack_preview.tscn": [
			"VBoxContainer/AttackerLabel",
			"VBoxContainer/DefenderLabel",
			"VBoxContainer/Buttons/ConfirmButton",
			"VBoxContainer/Buttons/CancelButton",
		],
		"res://scenes/battle/ui/tile_info_panel.tscn": [
			"VBoxContainer/TerrainLabel",
			"VBoxContainer/MoveCostLabel",
		],
		"res://scenes/story/story_player.tscn": [
			"DialogueBox",
			"DialogueBox/MarginContainer/VBoxContainer/CharacterNameLabel",
			"DialogueBox/MarginContainer/VBoxContainer/DialogueText",
			"ChoiceContainer",
		],
		"res://scenes/menu/main_menu.tscn": [
			"CenterContainer/VBoxContainer/NewGameButton",
			"CenterContainer/VBoxContainer/ContinueButton",
			"CenterContainer/VBoxContainer/SettingsButton",
			"CenterContainer/VBoxContainer/QuitButton",
		],
		"res://scenes/menu/battle_result_menu.tscn": [
			"MarginContainer/VBoxContainer/ResultLabel",
			"MarginContainer/VBoxContainer/SummaryLabel",
			"MarginContainer/VBoxContainer/PrimaryButton",
			"MarginContainer/VBoxContainer/SecondaryButton",
		],
		"res://scenes/menu/settings_menu.tscn": [
			"MarginContainer/VBoxContainer/BackButton",
		],
		"res://scenes/menu/save_load_menu.tscn": [
			"MarginContainer/VBoxContainer/LoadSlot1Button",
			"MarginContainer/VBoxContainer/BackButton",
		],
	}

	for sp in scene_paths:
		var packed := load(sp) as PackedScene
		if not packed:
			details.append("FAILED to load: %s" % sp)
			all_pass = false
		else:
			var can_instantiate := packed.can_instantiate()
			if can_instantiate:
				var instance := packed.instantiate()
				var missing_nodes: Array[String] = []
				for node_path in required_nodes.get(sp, []):
					if instance.get_node_or_null(NodePath(node_path)) == null:
						missing_nodes.append(node_path)
				if missing_nodes.is_empty():
					details.append("OK: %s" % sp)
				else:
					details.append("MISSING NODES: %s -> %s" % [sp, ", ".join(missing_nodes)])
					all_pass = false
				instance.free()
			else:
				details.append("CANNOT INSTANTIATE: %s" % sp)
				all_pass = false

	return {
		"passed": all_pass,
		"message": "%d/%d scenes loaded" % [details.filter(func(d): return d.begins_with("OK")).size(), scene_paths.size()],
		"details": details.filter(func(d): return not d.begins_with("OK"))
	}
