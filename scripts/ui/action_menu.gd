extends Panel

class_name ActionMenu

signal move_selected()
signal attack_selected()
signal skill_selected()
signal wait_selected()

func show_for_unit(unit: UnitActor) -> void:
	var can_move := unit.can_move()
	var can_act := unit.can_act()
	%MoveButton.visible = can_move
	%AttackButton.visible = can_act
	%SkillButton.visible = can_act and not unit.runtime_state.skills.is_empty()
	%WaitButton.visible = true
	show()

func _on_move_pressed() -> void:
	move_selected.emit()

func _on_attack_pressed() -> void:
	attack_selected.emit()

func _on_skill_pressed() -> void:
	skill_selected.emit()

func _on_wait_pressed() -> void:
	wait_selected.emit()
