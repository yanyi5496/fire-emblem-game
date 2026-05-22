extends CanvasLayer

class_name SettingsMenu

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.SETTINGS)

func _on_back_pressed() -> void:
	SceneRouter.goto("main_menu")
