extends Node

class_name BootController

func _ready() -> void:
	_apply_theme()
	_apply_saved_settings()
	if SceneRouter:
		GameState.set_phase(GameState.GamePhase.TITLE)
		SceneRouter.goto("main_menu")
	else:
		push_error("SceneRouter autoload not available")

func _apply_saved_settings() -> void:
	var settings: Dictionary = GameState.settings
	if settings.is_empty():
		_load_settings_from_disk()
		settings = GameState.settings
	if settings.has("master_volume"):
		AudioManager.set_volume(AudioManager.Bus.MASTER, int(settings["master_volume"]))
	if settings.has("bgm_volume"):
		AudioManager.set_volume(AudioManager.Bus.BGM, int(settings["bgm_volume"]))
	if settings.has("sfx_volume"):
		AudioManager.set_volume(AudioManager.Bus.SFX, int(settings["sfx_volume"]))
	if settings.get("fullscreen", false):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif settings.has("window_width") and settings.has("window_height"):
		DisplayServer.window_set_size(Vector2i(int(settings["window_width"]), int(settings["window_height"])))

const _SETTINGS_FILE := "user://settings.cfg"

func _load_settings_from_disk() -> void:
	if not FileAccess.file_exists(_SETTINGS_FILE):
		return
	var file := FileAccess.open(_SETTINGS_FILE, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		var data := json.get_data() as Dictionary
		if data:
			for key in data:
				GameState.settings[key] = data[key]

func _apply_theme() -> void:
	var theme := Theme.new()
	const Normal := preload("res://assets/sprites/ui/ui_button_normal.png")
	const Hover := preload("res://assets/sprites/ui/ui_button_hover.png")
	const Pressed := preload("res://assets/sprites/ui/ui_button_pressed.png")

	var btn_normal := StyleBoxTexture.new()
	btn_normal.texture = Normal
	var btn_hover := StyleBoxTexture.new()
	btn_hover.texture = Hover
	var btn_pressed := StyleBoxTexture.new()
	btn_pressed.texture = Pressed

	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_stylebox("hover", "Button", btn_hover)
	theme.set_stylebox("pressed", "Button", btn_pressed)
	theme.set_color("font_color", "Button", Color(0.9, 0.9, 0.85, 1))
	theme.set_color("font_hover_color", "Button", Color(1, 0.95, 0.7, 1))
	theme.set_color("font_pressed_color", "Button", Color(1, 1, 1, 1))
	theme.set_font_size("font_size", "Button", 18)

	var panel_bg := StyleBoxFlat.new()
	panel_bg.bg_color = Color(0.1, 0.12, 0.18, 0.85)
	panel_bg.set_corner_radius_all(6)
	theme.set_stylebox("panel", "Panel", panel_bg)

	theme.set_color("font_color", "Label", Color(0.9, 0.9, 0.85, 1))
	theme.set_font_size("font_size", "Label", 16)
	theme.set_color("font_color", "HSlider", Color(0.9, 0.9, 0.85, 1))
	theme.set_color("font_color", "CheckBox", Color(0.9, 0.9, 0.85, 1))

	_apply_default_font(theme)

	get_tree().root.theme = theme

func _apply_default_font(theme: Theme) -> void:
	var sys_font := SystemFont.new()
	sys_font.font_names = PackedStringArray(["Microsoft YaHei", "SimHei", "Noto Sans SC"])
	sys_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	theme.default_font = sys_font
	theme.default_font_size = 16
