extends Node

enum TransitionType {
	FADE,
	INSTANT,
}

signal before_scene_change(from_scene: String, to_scene: String)
signal after_scene_change(to_scene: String)

var _fade_overlay: ColorRect = null

func _ready() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "TransitionLayer"
	add_child(canvas)
	_fade_overlay = ColorRect.new()
	_fade_overlay.name = "FadeOverlay"
	_fade_overlay.color = Color.BLACK
	_fade_overlay.modulate.a = 0.0
	_fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_overlay.anchors_preset = Control.PRESET_FULL_RECT
	canvas.add_child(_fade_overlay)

func goto(scene_key: String, params: Dictionary = {}) -> void:
	before_scene_change.emit("", scene_key)
	var scene_path := _get_scene_path(scene_key)
	_do_fade_transition(scene_path)
	after_scene_change.emit(scene_key)

func _do_fade_transition(scene_path: String) -> void:
	if not _fade_overlay:
		get_tree().change_scene_to_file(scene_path)
		return
	var tween := create_tween()
	_fade_overlay.modulate.a = 0.0
	tween.tween_property(_fade_overlay, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
		_fade_out()
	)

func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_fade_overlay, "modulate:a", 0.0, 0.3)



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
		"result":
			return "res://scenes/menu/battle_result_menu.tscn"
		"story":
			return "res://scenes/story/story_player.tscn"
		"boot":
			return "res://scenes/boot/boot_scene.tscn"
		_:
			push_error("Unknown scene key: %s" % key)
			return "res://scenes/boot/boot_scene.tscn"
