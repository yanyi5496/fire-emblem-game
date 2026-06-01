extends CanvasLayer

class_name BattleHUD

signal end_turn_pressed()
signal save_pressed()

const STAT_DISPLAY_NAMES := {
	"hp": "HP", "mp": "MP", "str": "力量", "mag": "魔力",
	"skl": "技巧", "spd": "速度", "def": "防御", "res": "魔防", "luk": "幸运",
}

@onready var turn_label: Label = $TurnLabel
@onready var unit_info: Panel = $UnitInfoPanel
@onready var unit_name_label: Label = $UnitInfoPanel/VBoxContainer/UnitNameLabel
@onready var hp_label: Label = $UnitInfoPanel/VBoxContainer/HPLabel
@onready var details_label: Label = $UnitInfoPanel/VBoxContainer/DetailsLabel
@onready var action_menu: Panel = $ActionMenu
@onready var attack_preview: Panel = $AttackPreview
@onready var end_turn_button: Button = $EndTurnButton
@onready var phase_overlay: ColorRect = $PhaseOverlay
@onready var phase_label: Label = $PhaseLabel
@onready var level_up_overlay: Panel = $LevelUpOverlay
@onready var level_up_unit_label: Label = $LevelUpOverlay/VBoxContainer/UnitLabel
@onready var level_up_stats_label: Label = $LevelUpOverlay/VBoxContainer/StatsLabel
@onready var level_up_confirm: Button = $LevelUpOverlay/VBoxContainer/ConfirmButton

var _phase_tween = null
var _level_up_queue: Array[Dictionary] = []

func update_turn_info(phase: String, turn: int) -> void:
	turn_label.text = "第 %d 回合 · %s 回合" % [turn, _phase_to_text(phase)]
	end_turn_button.visible = phase == "player"

func show_unit_info(unit) -> void:
	if not unit or not unit.runtime_state:
		hide_unit_info()
		return
	unit_info.show()
	unit_name_label.text = "%s Lv%d" % [unit.runtime_state.unit_name, unit.runtime_state.level]
	var s: Dictionary = unit.runtime_state.get_stats()
	hp_label.text = "HP %d/%d  MP %d/%d" % [s.get("hp", 0), s.get("max_hp", 0), s.get("mp", 0), s.get("max_mp", 0)]
	var weapon_name := "无"
	var wp_id: String = unit.runtime_state.equipped_weapon
	if wp_id != "":
		var wp: Dictionary = DataManager.get_weapon(wp_id)
		var dur: int = unit.runtime_state.get_weapon_durability(wp_id)
		var dur_color := "■" if dur > 5 else "!"
		weapon_name = "%s(%d)%s" % [wp.get("name", wp_id), dur, dur_color]
	var status_text: String = _status_text(unit.runtime_state.status_effects)
	details_label.text = "STR %d  MAG %d\nSKL %d  SPD %d\nDEF %d  RES %d\n武器: %s%s" % [
		s.get("str", 0), s.get("mag", 0),
		s.get("skl", 0), s.get("spd", 0),
		s.get("def", 0), s.get("res", 0),
		weapon_name,
		"\n" + status_text if status_text != "" else "",
	]

func _status_text(effects: Array[Dictionary]) -> String:
	var parts: Array[String] = []
	for e in effects:
		var eid: String = str(e.get("id", ""))
		if eid.begins_with("stat_buff_"):
			continue
		match eid:
			"poison": parts.append("中毒")
			"sleep": parts.append("睡眠")
			"paralysis": parts.append("麻痹")
			"silence": parts.append("沉默")
			"counter_stance": parts.append("反击姿态")
	return " ".join(parts)

func hide_unit_info() -> void:
	unit_info.hide()

func show_action_menu() -> void:
	action_menu.show()

func show_action_menu_for(unit) -> void:
	if action_menu and action_menu.has_method("show_for_view_model"):
		action_menu.show_for_view_model(_build_view_model(unit))
	elif action_menu and action_menu.has_method("show_for_unit"):
		action_menu.show_for_unit(unit)
	else:
		action_menu.show()

func _build_view_model(unit) -> Dictionary:
	if not unit or not unit.runtime_state:
		return {"can_move": false, "can_act": false, "has_ready_skill": false, "weapon_count": 0}
	var has_ready_skill := false
	for skill_id in unit.runtime_state.skills:
		var skill_data: Dictionary = DataManager.get_skill(skill_id)
		if skill_data.get("type", "") == "active" and unit.runtime_state.can_use_skill(skill_id):
			has_ready_skill = true
			break
	return {
		"can_move": unit.can_move(),
		"can_act": unit.can_act(),
		"has_ready_skill": has_ready_skill,
		"weapon_count": unit.runtime_state.inventory.size(),
	}

func hide_action_menu() -> void:
	action_menu.hide()

func show_attack_preview(result: Dictionary) -> void:
	if attack_preview and attack_preview.has_method("show_result"):
		attack_preview.show_result(result)
	else:
		attack_preview.show()

func hide_attack_preview() -> void:
	attack_preview.hide()

func show_phase_transition(phase: String) -> void:
	var phase_text := _phase_to_text(phase)
	phase_label.text = "%s回合" % phase_text
	phase_label.visible = true
	phase_overlay.visible = true
	phase_overlay.color = Color(0.1, 0.1, 0.15, 0.7)
	match phase:
		"player":
			phase_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
		"enemy":
			phase_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		"npc":
			phase_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	if _phase_tween:
		_phase_tween.kill()
	_phase_tween = create_tween()
	_phase_tween.tween_interval(1.2)
	_phase_tween.tween_callback(_hide_phase_transition)

func _hide_phase_transition() -> void:
	phase_overlay.visible = false
	phase_label.visible = false

func show_level_up(unit_id: String, stats: Dictionary) -> void:
	_level_up_queue.append({"unit_id": unit_id, "stats": stats})
	if not level_up_overlay.visible:
		_show_next_level_up()

func _show_next_level_up() -> void:
	if _level_up_queue.is_empty():
		level_up_overlay.visible = false
		return
	var entry: Dictionary = _level_up_queue.pop_front()
	var unit_id: String = entry["unit_id"]
	var stats: Dictionary = entry["stats"]
	var unit_data: Dictionary = DataManager.get_unit(unit_id)
	var display_name: String = str(unit_data.get("name", unit_id))
	level_up_unit_label.text = "%s 升级！" % display_name
	var stat_lines: Array[String] = []
	for stat_name in stats:
		var gain: int = int(stats[stat_name])
		if gain > 0:
			var display: String = STAT_DISPLAY_NAMES.get(stat_name, stat_name)
			stat_lines.append("%s +%d" % [display, gain])
	if stat_lines.is_empty():
		stat_lines.append("无属性提升")
	level_up_stats_label.text = "\n".join(stat_lines)
	level_up_overlay.visible = true

func _on_level_up_confirmed() -> void:
	_show_next_level_up()

func show_status_message(text: String) -> void:
	turn_label.text = text

func show_message(text: String) -> void:
	turn_label.text = text

func _phase_to_text(phase: String) -> String:
	match phase:
		"player": return "玩家"
		"enemy": return "敌方"
		"npc": return "友方"
		_:
			return phase

func show_save_feedback(turn: int, phase_text: String) -> void:
	turn_label.text = "第 %d 回合 · %s回合 · 已保存到槽位 1" % [turn, phase_text]

func _on_save_pressed() -> void:
	save_pressed.emit()

func _on_end_turn_pressed() -> void:
	end_turn_pressed.emit()

func _ready() -> void:
	if level_up_confirm and not level_up_confirm.pressed.is_connected(_on_level_up_confirmed):
		level_up_confirm.pressed.connect(_on_level_up_confirmed)