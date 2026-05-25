extends CanvasLayer

class_name SettingsMenu

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.SETTINGS)
	_load_settings()

@onready var _master_slider = $MarginContainer/VBoxContainer/MasterVolumeSlider
@onready var _bgm_slider = $MarginContainer/VBoxContainer/BgmVolumeSlider
@onready var _sfx_slider = $MarginContainer/VBoxContainer/SfxVolumeSlider
@onready var _fullscreen_check = $MarginContainer/VBoxContainer/FullscreenCheckBox

func _load_settings() -> void:
	var settings: Dictionary = GameState.settings
	_master_slider.value = settings.get("master_volume", 80)
	_bgm_slider.value = settings.get("bgm_volume", 70)
	_sfx_slider.value = settings.get("sfx_volume", 85)
	_fullscreen_check.button_pressed = settings.get("fullscreen", false)

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
