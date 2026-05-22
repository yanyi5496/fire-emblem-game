extends CanvasLayer

class_name SaveLoadMenu

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.SAVE_LOAD)

func _on_load_slot_pressed() -> void:
	if SaveManager.load_game(1).is_empty():
		return
	if GameState.current_map_id != "":
		SceneRouter.goto("battle")

func _on_back_pressed() -> void:
	SceneRouter.goto("main_menu")
