extends CanvasLayer

class_name BattleHUD

signal end_turn_pressed()

@onready var turn_label: Label = $TurnLabel
@onready var unit_info: Panel = $UnitInfoPanel
@onready var unit_name_label: Label = $UnitInfoPanel/UnitNameLabel
@onready var hp_label: Label = $UnitInfoPanel/HPLabel
@onready var action_menu: Panel = $ActionMenu
@onready var attack_preview: Panel = $AttackPreview

func update_turn_info(phase: String, turn: int) -> void:
	turn_label.text = "第 %d 回合 · %s 回合" % [turn, _phase_to_text(phase)]

func show_unit_info(unit: UnitActor) -> void:
	if not unit or not unit.runtime_state:
		hide_unit_info()
		return
	unit_info.show()
	unit_name_label.text = unit.runtime_state.unit_name
	var s := unit.runtime_state.get_stats()
	hp_label.text = "HP %d/%d" % [s.hp, s.max_hp]

func hide_unit_info() -> void:
	unit_info.hide()

func show_action_menu() -> void:
	action_menu.show()

func hide_action_menu() -> void:
	action_menu.hide()

func show_attack_preview(result: Dictionary) -> void:
	attack_preview.show()

func hide_attack_preview() -> void:
	attack_preview.hide()

func _phase_to_text(phase: String) -> String:
	match phase:
		"player": return "玩家"
		"enemy": return "敌方"
		"npc": return "友方"
		_:
			return phase
