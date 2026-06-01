extends CanvasLayer

class_name MainMenu

const DEFAULT_STORY_SCENE := "story"

@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.TITLE)
	GameState.set_resume_scene("main_menu")
	continue_button.disabled = not SaveManager.has_any_save()

func _on_new_game_pressed() -> void:
	GameState.reset()
	GameState.current_chapter = "chapter_01"
	GameState.current_map_id = "mvp_map_01"
	SceneRouter.goto(DEFAULT_STORY_SCENE)

func _on_continue_pressed() -> void:
	GameState.story_flags["_loading_mode"] = true
	SceneRouter.goto("save_load")

func _on_settings_pressed() -> void:
	SceneRouter.goto("settings")

func _on_quit_pressed() -> void:
	get_tree().quit()
