extends CanvasLayer

class_name SettingsMenu

const RESOLUTION_PRESETS := {
	"1280x720": Vector2i(1280, 720),
	"1366x768": Vector2i(1366, 768),
	"1600x900": Vector2i(1600, 900),
	"1920x1080": Vector2i(1920, 1080),
}

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.SETTINGS)
	_load_settings()

@onready var _master_slider = $MarginContainer/VBoxContainer/MasterVolumeSlider
@onready var _bgm_slider = $MarginContainer/VBoxContainer/BgmVolumeSlider
@onready var _sfx_slider = $MarginContainer/VBoxContainer/SfxVolumeSlider
@onready var _fullscreen_check = $MarginContainer/VBoxContainer/FullscreenCheckBox

var _resolution_option: OptionButton = null

func _init_resolution_option() -> void:
	_resolution_option = $MarginContainer/VBoxContainer/ResolutionOptionButton as OptionButton
	if not _resolution_option:
		return
	_resolution_option.clear()
	for key in RESOLUTION_PRESETS:
		_resolution_option.add_item(key)
	_resolution_option.item_selected.connect(_on_resolution_selected)

func _load_settings() -> void:
	_init_resolution_option()
	var settings: Dictionary = GameState.settings
	_master_slider.value = settings.get("master_volume", 80)
	_bgm_slider.value = settings.get("bgm_volume", 70)
	_sfx_slider.value = settings.get("sfx_volume", 85)
	_fullscreen_check.button_pressed = settings.get("fullscreen", false)
	if _resolution_option:
		var saved_res: Vector2i = Vector2i(
			int(settings.get("window_width", 1280)),
			int(settings.get("window_height", 720))
		)
		var index := -1
		for i in range(_resolution_option.item_count):
			var label: String = _resolution_option.get_item_text(i)
			if RESOLUTION_PRESETS.get(label, Vector2i.ZERO) == saved_res:
				index = i
				break
		if index >= 0:
			_resolution_option.select(index)
		else:
			_resolution_option.select(0)

func _save_settings() -> void:
	GameState.settings["master_volume"] = int(_master_slider.value)
	GameState.settings["bgm_volume"] = int(_bgm_slider.value)
	GameState.settings["sfx_volume"] = int(_sfx_slider.value)
	GameState.settings["fullscreen"] = _fullscreen_check.button_pressed
	AudioManager.set_volume(AudioManager.Bus.MASTER, int(_master_slider.value))
	AudioManager.set_volume(AudioManager.Bus.BGM, int(_bgm_slider.value))
	AudioManager.set_volume(AudioManager.Bus.SFX, int(_sfx_slider.value))
	if _fullscreen_check.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_resolution_selected(index: int) -> void:
	if not _resolution_option:
		return
	var label: String = _resolution_option.get_item_text(index)
	var size: Vector2i = RESOLUTION_PRESETS.get(label, Vector2i(1280, 720))
	GameState.settings["window_width"] = size.x
	GameState.settings["window_height"] = size.y
	if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_size(size)

func _on_master_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.set_volume(AudioManager.Bus.MASTER, int(_master_slider.value))

func _on_bgm_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.set_volume(AudioManager.Bus.BGM, int(_bgm_slider.value))

func _on_sfx_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		AudioManager.set_volume(AudioManager.Bus.SFX, int(_sfx_slider.value))

func _on_back_pressed() -> void:
	_save_settings()
	SceneRouter.goto("main_menu")
