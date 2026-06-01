extends CanvasLayer

class_name BattleResultMenu

const CHAPTER_FLOW := {
	"chapter_01": {
		"map_id": "mvp_map_01",
		"post_battle_story": "mvp_story_02.txt",
		"next_chapter": "",
	},
	"chapter_02": {
		"map_id": "mvp_map_05",
		"post_battle_story": "",
		"next_chapter": "",
	},
}
}

@onready var result_label: Label = $MarginContainer/VBoxContainer/ResultLabel
@onready var summary_label: Label = $MarginContainer/VBoxContainer/SummaryLabel
@onready var unit_result_container: VBoxContainer = $MarginContainer/VBoxContainer/UnitResultContainer
@onready var level_up_label: Label = $MarginContainer/VBoxContainer/LevelUpLabel
@onready var primary_button: Button = $MarginContainer/VBoxContainer/PrimaryButton

func _ready() -> void:
	GameState.set_phase(GameState.GamePhase.BATTLE_RESULT)
	GameState.set_resume_scene("result")
	var is_victory := GameState.latest_battle_result == "victory"
	result_label.text = "战斗%s" % ("胜利" if is_victory else "失败")
	summary_label.text = "地图：%s\n回合：%d" % [GameState.latest_battle_map_id, GameState.latest_battle_turns]
	primary_button.text = _primary_button_text(is_victory)
	_populate_unit_results()

func _populate_unit_results() -> void:
	for child in unit_result_container.get_children():
		child.queue_free()
	var units: Array = GameState.battle_units
	if units.is_empty():
		return
	var level_up_texts: Array[String] = []
	for unit_data in units:
		var unit_id: String = str(unit_data.get("unit_id", ""))
		var is_alive: bool = bool(unit_data.get("is_alive", true))
		var team: String = str(unit_data.get("team", ""))
		if team != "player":
			continue
		var name_text: String = _unit_display_name(unit_id)
		var hp: int = int(unit_data.get("current_hp", 0))
		var max_hp: int = 0
		var stats: Dictionary = unit_data.get("stats", {})
		if not stats.is_empty():
			max_hp = int(stats.get("max_hp", 0))
		else:
			max_hp = hp
		var status_icon := "♥" if is_alive else "✗"
		var line := "%s %s %d/%d" % [status_icon, name_text, hp, max_hp]
		var level: int = int(unit_data.get("level", 1))
		line += "  Lv%d" % level
		var label := Label.new()
		label.text = line
		if is_alive:
			label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
		else:
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		unit_result_container.add_child(label)
		if is_alive and level > 1:
			level_up_texts.append("%s → Lv%d" % [name_text, level])
	if not level_up_texts.is_empty():
		level_up_label.text = "升级: " + ", ".join(level_up_texts)
		level_up_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	elif is_victory():
		level_up_label.text = ""
	else:
		level_up_label.text = ""

func is_victory() -> bool:
	return GameState.latest_battle_result == "victory"

func _unit_display_name(unit_id: String) -> String:
	var data: Dictionary = DataManager.get_unit(unit_id)
	if not data.is_empty():
		return str(data.get("name", unit_id))
	return unit_id

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