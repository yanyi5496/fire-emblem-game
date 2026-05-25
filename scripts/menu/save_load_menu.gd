extends CanvasLayer

class_name SaveLoadMenu

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.SAVE_LOAD)

func _on_load_slot_pressed() -> void:
	if SaveManager.load_game(1).is_empty():
		return
	var next_scene := GameState.get_resume_scene()
	if next_scene != "main_menu":
		SceneRouter.goto(next_scene)

func _on_back_pressed() -> void:
	SceneRouter.goto("main_menu")
