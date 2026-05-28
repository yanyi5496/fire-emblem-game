extends CanvasLayer

class_name BattleHUD

signal end_turn_pressed()
signal save_pressed()

@onready var turn_label: Label = $TurnLabel
@onready var unit_info: Panel = $UnitInfoPanel
@onready var unit_name_label: Label = $UnitInfoPanel/VBoxContainer/UnitNameLabel
@onready var hp_label: Label = $UnitInfoPanel/VBoxContainer/HPLabel
@onready var details_label: Label = $UnitInfoPanel/VBoxContainer/DetailsLabel
@onready var action_menu: Panel = $ActionMenu
@onready var attack_preview: Panel = $AttackPreview

func update_turn_info(phase: String, turn: int) -> void:
	turn_label.text = "第 %d 回合 · %s 回合" % [turn, _phase_to_text(phase)]

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
		weapon_name = "%s(%d)" % [wp.get("name", wp_id), dur]
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