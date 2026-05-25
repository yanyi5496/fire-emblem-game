extends CanvasLayer

class_name BattleResultMenu

const CHAPTER_FLOW := {
	"chapter_01": {
		"map_id": "mvp_map_01",
		"post_battle_story": "mvp_story_02.txt",
		"next_chapter": "",
	}
}

@onready var result_label: Label = $MarginContainer/VBoxContainer/ResultLabel
@onready var summary_label: Label = $MarginContainer/VBoxContainer/SummaryLabel
@onready var primary_button: Button = $MarginContainer/VBoxContainer/PrimaryButton

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.BATTLE_RESULT)
	GameState.set_resume_scene("result")
	var is_victory := GameState.latest_battle_result == "victory"
	result_label.text = "战斗%s" % ("胜利" if is_victory else "失败")
	summary_label.text = "地图：%s\n回合：%d" % [GameState.latest_battle_map_id, GameState.latest_battle_turns]
	primary_button.text = _primary_button_text(is_victory)

func _on_primary_pressed() -> void:
	if GameState.latest_battle_result == "victory":
		var flow: Dictionary = CHAPTER_FLOW.get(GameState.current_chapter, {})
		var post_story := str(flow.get("post_battle_story", ""))
		if post_story != "":
			_prepare_transition(GameState.GamePhase.TITLE, 0)
			GameState.story_flags["%s_post_battle_pending" % GameState.current_chapter] = true
			GameState.current_map_id = ""
			GameState.set_resume_scene("story")
			SceneRouter.goto("story")
			return
		var next_map_id := _get_next_map_id(GameState.latest_battle_map_id)
		if next_map_id != "":
			_prepare_transition(GameState.GamePhase.TITLE, 1)
			GameState.current_map_id = next_map_id
			GameState.set_resume_scene("story")
			SceneRouter.goto("story")
			return
		_prepare_transition(GameState.GamePhase.TITLE, 0)
		GameState.current_map_id = ""
		GameState.set_resume_scene("main_menu")
		SceneRouter.goto("main_menu")
		return
	_prepare_transition(GameState.GamePhase.TITLE, 1)
	GameState.current_map_id = GameState.latest_battle_map_id
	GameState.set_resume_scene("battle")
	SceneRouter.goto("battle")

func _on_secondary_pressed() -> void:
	_prepare_transition(GameState.GamePhase.TITLE, 0)
	GameState.current_map_id = ""
	GameState.set_resume_scene("main_menu")
	SceneRouter.goto("main_menu")

func _primary_button_text(is_victory: bool) -> String:
	if not is_victory:
		return "重新挑战"
	var flow: Dictionary = CHAPTER_FLOW.get(GameState.current_chapter, {})
	if str(flow.get("post_battle_story", "")) != "":
		return "继续"
	if _get_next_map_id(GameState.latest_battle_map_id) != "":
		return "下一关"
	return "完成章节"

func _get_next_map_id(current_map_id: String) -> String:
	var flow: Dictionary = CHAPTER_FLOW.get(GameState.current_chapter, {})
	var next_chapter: String = str(flow.get("next_chapter", ""))
	return next_chapter

func _prepare_transition(target_phase: GameState.GamePhase, next_turn: int) -> void:
	GameState.clear_battle_snapshot()
	GameState.set_turn(next_turn)
	GameState.set_phase(target_phase)
