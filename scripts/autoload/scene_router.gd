extends Node

class_name SceneRouter

enum TransitionType {
	FADE,
	INSTANT,
}

signal before_scene_change(from_scene: String, to_scene: String)
signal after_scene_change(to_scene: String)

func goto(scene_key: String, params: Dictionary = {}) -> void:
	before_scene_change.emit("", scene_key)
	var scene_path := _get_scene_path(scene_key)
	var result := get_tree().change_scene_to_file(scene_path)
	if result != OK:
		push_error("Failed to load scene: ", scene_path)
		return
	after_scene_change.emit(scene_key)

func _get_scene_path(key: String) -> String:
	match key:
		"main_menu":
			return "res://scenes/menu/main_menu.tscn"
		"settings":
			return "res://scenes/menu/settings_menu.tscn"
		"save_load":
			return "res://scenes/menu/save_load_menu.tscn"
		"battle":
			return "res://scenes/battle/battle_scene.tscn"
		"story":
			return "res://scenes/story/story_player.tscn"
		"boot":
			return "res://scenes/boot/boot_scene.tscn"
		_:
			push_error("Unknown scene key: ", key)
			return "res://scenes/boot/boot_scene.tscn"
