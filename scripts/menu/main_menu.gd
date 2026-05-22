extends CanvasLayer

class_name MainMenu

const DEFAULT_STORY_SCENE := "story"

@onready var continue_button: Button = $MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.TITLE)
	continue_button.disabled = not SaveManager.has_any_save()

func _on_new_game_pressed() -> void:
	GameState.reset()
	GameState.current_chapter = "chapter_01"
	GameState.current_map_id = "mvp_map_01"
	SceneRouter.goto(DEFAULT_STORY_SCENE)

func _on_continue_pressed() -> void:
	if SaveManager.load_game(1).is_empty():
		return
	if GameState.current_map_id != "":
		SceneRouter.goto("battle")

func _on_settings_pressed() -> void:
	SceneRouter.goto("settings")

func _on_quit_pressed() -> void:
	get_tree().quit()
