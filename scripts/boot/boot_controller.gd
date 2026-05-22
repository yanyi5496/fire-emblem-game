extends Node

class_name BootController

func _ready() -> void:
	if SceneRouter:
		GameState.set_phase(GameState.GamePhase.TITLE)
		SceneRouter.goto("main_menu")
	else:
		push_error("SceneRouter autoload not available")
